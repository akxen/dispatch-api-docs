# Running a model
An online queue is used to coordinate the task of formulating and solving mathematical programs. Users submit parameters to the queue which creates a new 'job'. A pool of 'workers' monitor this queue for new jobs. If a worker is available (i.e. it is not currently processing a job) it will pick the job off the queue and then formulate and solve a mathematical program using the inputs provided. The worker then posts the optimisation model's results back to the queue, and marks the job as 'finished'. Results can then be accessed by the user.

This notebook describes how to submit a case file parameters and retrieve results from the queue.

## Imports and authentication


```python
import os
import json

import requests
import xmltodict
import pandas as pd

import IPython.display as display
```

First specify the base URL for API calls.


```python
# Base URL endpoint for the Dispatch API
base_url = 'http://nemde-api-host:8080/api/v1/'
```

## Load case file
Case files contain parameters used by the NEMDE when determining dispatch targets for generators and loads. The API uses selected inputs from these case files when formulating a mathematical program that approximates the NEMDE's operation (see the [parameter reference page](/parameter-reference) for a description of the inputs used).

Each case file is identified by a case ID, e.g. `20201101001`, which has the following format:

```
{year}{month}{day}{interval_id}
```

Interval IDs range from 001-288 and are used to identify each 5 minute interval within a 24 hour period. 

As each trading day begins at 4.00am, the case ID `20201101001` corresponds to the trading interval which starts at `2020-11-01 04:00:00` and ends at `2020-11-01 04:05:00`. When NEMDE is run at approximately `04:00:00` it produces dispatch targets that generators and loads should meet at `04:05:00`. The following table illustrates the mapping between case IDs and the start and end times for selected dispatch intervals.


| Case ID | Interval start | Interval end |
| :------: | :-------------: | :-----------: |
| 20201101001 | 2020-11-01 04:00:00 | 2020-11-01 04:05:00 |
| 20201101002 | 2020-11-01 04:05:00 | 2020-11-01 04:10:00 |
| 20201101003 | 2020-11-01 04:10:00 | 2020-11-01 04:15:00 |
| ... | ... | ... |
| 20201101287 | 2020-11-02 03:50:00 | 2020-11-02 03:55:00 |
| 20201101288 | 2020-11-02 03:55:00 | 2020-11-02 04:00:00 |


The following function loads a case file in XML format and converts it to a Python dictionary.


```python
def convert_casefile(path_to_file):
    """Load a historical NEMDE case file and convert it to a dict"""
    
    # Read case file contents
    with open(path_to_file, 'r') as f:
        casefile = f.read()
    
    # Force these nodes to always return lists
    force_list = ('Trade', 'TradeTypePriceStructure',)

    return xmltodict.parse(casefile, force_list=force_list)

casefile = convert_casefile('../../data/NEMSPDOutputs_2021040100100.loaded')
```

## Case file components
Case files describe the state of the system at the start of a dispatch interval, and also include forecasts for demand and intermittent generation at the end of the interval. A nested data structure, in this case a Python dictionary, organises data into logical components.

Those familiar with NEMDE case files in XML format may recognise the following data structure. In fact, the dictionary is obtained by converting a NEMDE case file in XML format to a Python dictionary. See [this tutorial](/tutorials/converting-a-case-file) to learn how to convert your own NEMDE XML files into a format that can be consumed by the Dispatch API.

At the dictionary's root there is a single key, `NEMSPDCaseFile`:


```python
casefile.keys()
```




    odict_keys(['NEMSPDCaseFile'])



The dictionary can be traversed by 'getting' the value for a given key, in this case `NEMSPDCaseFile`, and looking at its constituent components. Here we can see there are three nested keys:


```python
casefile.get('NEMSPDCaseFile').keys()
```




    odict_keys(['NemSpdInputs', 'NemSpdOutputs', 'SolutionAnalysis'])



| Key | Description |
| :--------- | :----------- |
| NemSpdInputs | Parameters describing the system's state |
| NemSpdOutputs | NEMDE solution for each trader (generator / load), generic constraint, interconnector, and region |
| SolutionAnalysis | Price setting results |

While NEMDE case files provide a convenient data structure describing parameters used to set dispatch targets, there are a limitations associated with their design. For instance, some parameters are duplicated, while others may be ignored. Users seeking to modify case files should consult the [parameter reference page](/parameter-reference) to see which parameters can be meaningfully modified when using the Dispatch API.

## Submitting a job
For now let's run the case file without modifying any of its components. The body of the request is simply a dictionary with ``"casefile"`` as the key, and the case file dictionay as its corresponding value:

```
body = {"casefile": casefile}
```

A POST request is submitted to `https://dispatch.envector.com/api/v1/jobs/create`

The response contains information pertaining to the newly created job, including a job ID which will be used when querying results once they become available.


```python
def submit_casefile(base_url, casefile):
    """Submit case file to the job queue"""

    # Construct request body and URL
    body = {'casefile': casefile}
    url = base_url + 'jobs/create'
    
    # Send job to queue and return job meta data
    response = requests.post(url=url, json=body)
    
    return response.json()


# Submit job and inspect meta data
job_info = submit_casefile(base_url=base_url, casefile=casefile)
job_info
```




    {'job_id': '77b379d4-26e6-401b-8152-ca2e5482c658',
     'created_at': '2021-08-07T13:38:20.741817Z',
     'enqueued_at': '2021-08-07T13:38:20.884427Z',
     'timeout': 180,
     'status': 'queued',
     'label': None}



A pool of workers monitor the queue to which the job is posted. If a worker is available it will formulate and run the optimisation model using the inputs provided. Results are then posted back to the queue for retrieval by the user. 

The following URLs become available once a job has been submitted, allowing users to check the job's status, examine job results, or delete the job:

| URL | Description |
| :--- | :----------- |
| `http://nemde-api-host/api/v1/jobs/{job_id}/status` | Get job status |
| `http://nemde-api-host/api/v1/jobs/{job_id}/results` | Get job results |
| `http://nemde-api-host/api/v1/jobs/{job_id}/delete` | Delete job |

For example, if the job ID is `04c66262-6144-444d-98bf-00c21cb955dd`, the URL to get the job's status would be:

```
http://nemde-api-host/api/v1/jobs/04c66262-6144-444d-98bf-00c21cb955dd/status
```

Let's check the job's status.


```python
def check_job_status(base_url, job_id):
    """Check job status given a job ID"""
    
    url = base_url + f'jobs/{job_id}/status'

    return requests.get(url=url).json()


# Check job status
job_id = job_info.get('job_id')
check_job_status(base_url=base_url, job_id=job_id)
```




    {'job_id': '77b379d4-26e6-401b-8152-ca2e5482c658',
     'status': 'started',
     'created_at': '2021-08-07T13:38:20.741817',
     'enqueued_at': '2021-08-07T13:38:20.884427',
     'started_at': '2021-08-07T13:38:21.221078',
     'ended_at': None,
     'timeout': 180,
     'label': None}



We can see a worker has started to process the job. It typically takes 30s for a worker to complete a job once started. After waiting a short period we can check the status again.


```python
check_job_status(base_url=base_url, job_id=job_id)
```




    {'job_id': '77b379d4-26e6-401b-8152-ca2e5482c658',
     'status': 'finished',
     'created_at': '2021-08-07T13:38:20.741817',
     'enqueued_at': '2021-08-07T13:38:20.884427',
     'started_at': '2021-08-07T13:38:21.386579',
     'ended_at': '2021-08-07T13:39:12.951867',
     'timeout': 180,
     'label': None}



## Retrieving results
Once the job has finished we can access its results.


```python
def get_job_results(base_url, job_id):
    """Extract job results from the queue"""
    
    url = base_url + f'jobs/{job_id}/results'   
    response = requests.get(url=url)
    
    return response.json()


# Get job results from the queue
results = get_job_results(base_url=base_url, job_id=job_id)
```

<span style="color:red">Note: completed jobs are only retained in the queue for 2 hours, at which point the job (and results) are deleted.</span>

The value corresponding to the `results` key contains the solution reported by the worker. Let's use Pandas to examine the output.


```python
region_solution = results.get('results').get('output').get('RegionSolution')

# Convert to markdown to display results
region_solution_md = pd.DataFrame(region_solution).to_markdown(index=False)
display.Markdown(region_solution_md)
```




| @RegionID   |     @CaseID |   @Intervention |   @EnergyPrice |   @DispatchedGeneration |   @DispatchedLoad |   @FixedDemand |   @NetExport |   @SurplusGeneration |   @R6Dispatch |   @R60Dispatch |   @R5Dispatch |   @R5RegDispatch |   @L6Dispatch |   @L60Dispatch |   @L5Dispatch |   @L5RegDispatch |   @ClearedDemand |
|:------------|------------:|----------------:|---------------:|------------------------:|------------------:|---------------:|-------------:|---------------------:|--------------:|---------------:|--------------:|-----------------:|--------------:|---------------:|--------------:|-----------------:|-----------------:|
| NSW1        | 20210401001 |               0 |        38.2172 |                5127.54  |               200 |        6330.79 |    -1403.26  |                    0 |       261     |       251      |       141     |             88   |        91     |        142     |       67      |           33     |         6576.14  |
| QLD1        | 20210401001 |               0 |        32.25   |                6278.72  |                 0 |        5322.13 |      956.591 |                    0 |        75     |        53      |       107.915 |             23.2 |         0     |          0     |        0      |           59.875 |         5362.13  |
| SA1         | 20210401001 |               0 |        37.2465 |                 810.756 |                10 |        1065.3  |     -264.539 |                    0 |       142.829 |        77.5837 |       121     |             54.8 |       137     |         69     |       86      |           57.125 |         1077.47  |
| TAS1        | 20210401001 |               0 |        31.7702 |                1224.95  |                 0 |         991.98 |      232.971 |                    0 |        33     |        82.2457 |         0     |             49   |        56.166 |        152.495 |       50      |           50     |          996.513 |
| VIC1        | 20210401001 |               0 |        34.4678 |                4729.57  |                 0 |        4134.2  |      595.377 |                    0 |       105     |       153      |        98     |              5   |        25     |         31     |       52.5805 |           10     |         4159.28  |




```python
interconnector_solution = results.get('results').get('output').get('InterconnectorSolution')

# Convert to markdown to display results
interconnector_solution_md = pd.DataFrame(interconnector_solution).to_markdown(index=False)
display.Markdown(interconnector_solution_md)
```




| @InterconnectorID   |     @CaseID |   @Intervention |    @Flow |   @Losses |   @Deficit |
|:--------------------|------------:|----------------:|---------:|----------:|-----------:|
| N-Q-MNSP1           | 20210401001 |               0 |  -97     |  5.32865  |          0 |
| NSW1-QLD1           | 20210401001 |               0 | -819.585 | 65.3249   |          0 |
| T-V-MNSP1           | 20210401001 |               0 |  228.438 |  4.53231  |          0 |
| V-S-MNSP1           | 20210401001 |               0 |   63     |  0.102114 |          0 |
| V-SA                | 20210401001 |               0 |  203.717 |  8.27106  |          0 |
| VIC1-NSW1           | 20210401001 |               0 |  532.012 | 24.9029   |          0 |




```python
trader_solution = results.get('results').get('output').get('TraderSolution')

# Convert to markdown to display results
trader_solution_md = pd.DataFrame(trader_solution).head().to_markdown(index=False)
display.Markdown(trader_solution_md)
```




| @TraderID   |     @CaseID |   @Intervention |   @EnergyTarget |   @R6Target |   @R60Target |   @R5Target |   @R5RegTarget |   @L6Target |   @L60Target |   @L5Target |   @L5RegTarget |   @R6Violation |   @R60Violation |   @R5Violation |   @R5RegViolation |   @L6Violation |   @L60Violation |   @L5Violation |   @L5RegViolation |   @RampUpRate |   @RampDnRate |   @FSTargetMode |
|:------------|------------:|----------------:|----------------:|------------:|-------------:|------------:|---------------:|------------:|-------------:|------------:|---------------:|---------------:|----------------:|---------------:|------------------:|---------------:|----------------:|---------------:|------------------:|--------------:|--------------:|----------------:|
| AGLHAL      | 20210401001 |               0 |               0 |           0 |            0 |           0 |              0 |           0 |            0 |           0 |              0 |              0 |               0 |              0 |                 0 |              0 |               0 |              0 |                 0 |           720 |           720 |               0 |
| AGLSOM      | 20210401001 |               0 |               0 |           0 |            0 |           0 |              0 |           0 |            0 |           0 |              0 |              0 |               0 |              0 |                 0 |              0 |               0 |              0 |                 0 |           480 |           480 |               0 |
| ANGAST1     | 20210401001 |               0 |               0 |           0 |            0 |           0 |              0 |           0 |            0 |           0 |              0 |              0 |               0 |              0 |                 0 |              0 |               0 |              0 |                 0 |           840 |           840 |             nan |
| APD01       | 20210401001 |               0 |               0 |          31 |           90 |          45 |              0 |           0 |            0 |           0 |              0 |              0 |               0 |              0 |                 0 |              0 |               0 |              0 |                 0 |           nan |           nan |             nan |
| ARWF1       | 20210401001 |               0 |               0 |           0 |            0 |           0 |              0 |           0 |            0 |           0 |              0 |              0 |               0 |              0 |                 0 |              0 |               0 |              0 |                 0 |          1200 |           600 |             nan |



## Summary
This tutorial demonstrates the basic functionality of the NEMDE API. Two key components have been introduced: the ability to interact with historical case files, and methods that facilitate interaction with an online queue. Future tutorials will discuss how to modify case files, perform scenario analyses, and also introduce more advanced workflows using additional NEMDE API features.
