# Modifying a case file

The NEMDE API allows users to perform numerical experiments. By augmenting a selected case file parameter, while keeping all other parameters constant, the relationship between dispatch outcomes and the parameter under investigation can be examined.

The following sections discuss strategies that can be used to modify case files. While this notebook uses Python, it's possible to use other programming languages and workflows. The NEMDE API simply expects data in JSON format - so long as the inputs are correctly structured, the API is agnostic as to the technology used to edit and submit the case file.

## Imports and authentication


```python
import os
import json

import requests
import xmltodict
import pandas as pd
from jsonpath_ng import jsonpath
from jsonpath_ng.ext import parse

# Base URL endpoint for the NEMDE API
base_url = 'http://nemde-api-host:8080/api/v1/'
```

## Approach
Case files contain tens of thousands of parameters. While it's possible to design a completely customised case file, users should note the NEMDE API expects case files to be submitted in a standard format. Errors introduced when constructing a case file will almost certainly result in the model failing to return a solution.

For now let's use data from a historical case file and only modify selected components. We can proceed by first loading a case file.


```python
def convert_casefile(path_to_file):
    """Load a historical NEMDE case file and convert it to a dict"""
    
    # Read case file contents
    with open(path_to_file, 'r') as f:
        casefile = f.read()
    
    # Force these nodes to always return lists
    force_list = ('Trade', 'TradeTypePriceStructure',)

    return xmltodict.parse(casefile, force_list=force_list)


# Load case file and convert to JSON
casefile = convert_casefile('../../data/NEMSPDOutputs_2021040100100.loaded')
```

## Method 1 - Traverse dictionary
The simplest strategy is to traverse the case file dictionary and update parameters directly. The [parameter reference page](/nemde-api-docs/parameter-reference) can be used to see which parameters can be meaningfully updated.

Let's update the Demand Forecast (`@DF`) parameter for South Australia as an example. This parameter corresponds to the amount by which demand is expected to change over the dispatch interval. From the [parameter reference page](/nemde-api-docs/parameter-reference/#demand-forecast) we can see the path to this parameter is as follows:

```
NEMSPDCaseFile.NemSpdInputs.PeriodCollection.Period.RegionPeriodCollection.RegionPeriod[?(@RegionID="{region_id}")].@DF
```

Using this path we can traverse nodes within the dictionary:


```python
regions = (casefile.get('NEMSPDCaseFile').get('NemSpdInputs')
           .get('PeriodCollection').get('Period')
           .get('RegionPeriodCollection').get('RegionPeriod'))
regions
```




    [OrderedDict([('@RegionID', 'NSW1'),
                  ('@DF', '50.11376953125'),
                  ('@DemandForecast', '6575.22802734375'),
                  ('@Suspension_Schedule_Energy_Price', '34.66'),
                  ('@Suspension_Schedule_R6_Price', '1.01'),
                  ('@Suspension_Schedule_R60_Price', '1.41'),
                  ('@Suspension_Schedule_R5_Price', '0.76'),
                  ('@Suspension_Schedule_RReg_Price', '11.18'),
                  ('@Suspension_Schedule_L6_Price', '0.45'),
                  ('@Suspension_Schedule_L60_Price', '1.19'),
                  ('@Suspension_Schedule_L5_Price', '0.39'),
                  ('@Suspension_Schedule_LReg_Price', '9.72')]),
     OrderedDict([('@RegionID', 'QLD1'),
                  ('@DF', '1.39823298286458'),
                  ('@DemandForecast', '5362.80249'),
                  ('@Suspension_Schedule_Energy_Price', '35.01'),
                  ('@Suspension_Schedule_R6_Price', '1.01'),
                  ('@Suspension_Schedule_R60_Price', '1.41'),
                  ('@Suspension_Schedule_R5_Price', '0.76'),
                  ('@Suspension_Schedule_RReg_Price', '11.18'),
                  ('@Suspension_Schedule_L6_Price', '0.45'),
                  ('@Suspension_Schedule_L60_Price', '1.19'),
                  ('@Suspension_Schedule_L5_Price', '0.39'),
                  ('@Suspension_Schedule_LReg_Price', '9.72')]),
     OrderedDict([('@RegionID', 'SA1'),
                  ('@DF', '5.0419807434082'),
                  ('@DemandForecast', '1075.27025222778'),
                  ('@Suspension_Schedule_Energy_Price', '32.23'),
                  ('@Suspension_Schedule_R6_Price', '1.01'),
                  ('@Suspension_Schedule_R60_Price', '1.41'),
                  ('@Suspension_Schedule_R5_Price', '0.76'),
                  ('@Suspension_Schedule_RReg_Price', '11.18'),
                  ('@Suspension_Schedule_L6_Price', '0.39'),
                  ('@Suspension_Schedule_L60_Price', '2.93'),
                  ('@Suspension_Schedule_L5_Price', '0.37'),
                  ('@Suspension_Schedule_LReg_Price', '9.7')]),
     OrderedDict([('@RegionID', 'TAS1'),
                  ('@DF', '2.3228759765625'),
                  ('@DemandForecast', '997.246337890625'),
                  ('@Suspension_Schedule_Energy_Price', '26.84'),
                  ('@Suspension_Schedule_R6_Price', '9.46'),
                  ('@Suspension_Schedule_R60_Price', '8.99'),
                  ('@Suspension_Schedule_R5_Price', '0.91'),
                  ('@Suspension_Schedule_RReg_Price', '11.16'),
                  ('@Suspension_Schedule_L6_Price', '1.27'),
                  ('@Suspension_Schedule_L60_Price', '2.21'),
                  ('@Suspension_Schedule_L5_Price', '0.35'),
                  ('@Suspension_Schedule_LReg_Price', '9.15')]),
     OrderedDict([('@RegionID', 'VIC1'),
                  ('@DF', '49.33447265625'),
                  ('@DemandForecast', '4157.650390625'),
                  ('@Suspension_Schedule_Energy_Price', '22.54'),
                  ('@Suspension_Schedule_R6_Price', '1.01'),
                  ('@Suspension_Schedule_R60_Price', '1.41'),
                  ('@Suspension_Schedule_R5_Price', '0.76'),
                  ('@Suspension_Schedule_RReg_Price', '11.18'),
                  ('@Suspension_Schedule_L6_Price', '0.45'),
                  ('@Suspension_Schedule_L60_Price', '1.19'),
                  ('@Suspension_Schedule_L5_Price', '0.39'),
                  ('@Suspension_Schedule_LReg_Price', '9.72')])]



Once we reach the `RegionPeriod` node we encounter a list of dictionaries describing parameters for each region. We can loop through the list and update the `@DF` parameter for South Australia (i.e. the dictionary with `@RegionID == 'SA1'`).


```python
# Updating the @DF parameter for South Australia
for i in regions:
    if i.get('@RegionID') == 'SA1':
        i['@DF'] = 20
```

<span style="color:blue">**Note:** By default all values within a case file are of type 'string'. Strings, floats or integers can be used when updating case file parameters as types are converted in a preprocessing step before formulating a mathematical program from the inputs. Strings should be used when updating flags e.g. parameters that take on a value of '1' or '0'.</span>

Checking the value has been updated.


```python
(casefile.get('NEMSPDCaseFile').get('NemSpdInputs')
 .get('PeriodCollection').get('Period')
 .get('RegionPeriodCollection').get('RegionPeriod'))
```




    [OrderedDict([('@RegionID', 'NSW1'),
                  ('@DF', '50.11376953125'),
                  ('@DemandForecast', '6575.22802734375'),
                  ('@Suspension_Schedule_Energy_Price', '34.66'),
                  ('@Suspension_Schedule_R6_Price', '1.01'),
                  ('@Suspension_Schedule_R60_Price', '1.41'),
                  ('@Suspension_Schedule_R5_Price', '0.76'),
                  ('@Suspension_Schedule_RReg_Price', '11.18'),
                  ('@Suspension_Schedule_L6_Price', '0.45'),
                  ('@Suspension_Schedule_L60_Price', '1.19'),
                  ('@Suspension_Schedule_L5_Price', '0.39'),
                  ('@Suspension_Schedule_LReg_Price', '9.72')]),
     OrderedDict([('@RegionID', 'QLD1'),
                  ('@DF', '1.39823298286458'),
                  ('@DemandForecast', '5362.80249'),
                  ('@Suspension_Schedule_Energy_Price', '35.01'),
                  ('@Suspension_Schedule_R6_Price', '1.01'),
                  ('@Suspension_Schedule_R60_Price', '1.41'),
                  ('@Suspension_Schedule_R5_Price', '0.76'),
                  ('@Suspension_Schedule_RReg_Price', '11.18'),
                  ('@Suspension_Schedule_L6_Price', '0.45'),
                  ('@Suspension_Schedule_L60_Price', '1.19'),
                  ('@Suspension_Schedule_L5_Price', '0.39'),
                  ('@Suspension_Schedule_LReg_Price', '9.72')]),
     OrderedDict([('@RegionID', 'SA1'),
                  ('@DF', 20),
                  ('@DemandForecast', '1075.27025222778'),
                  ('@Suspension_Schedule_Energy_Price', '32.23'),
                  ('@Suspension_Schedule_R6_Price', '1.01'),
                  ('@Suspension_Schedule_R60_Price', '1.41'),
                  ('@Suspension_Schedule_R5_Price', '0.76'),
                  ('@Suspension_Schedule_RReg_Price', '11.18'),
                  ('@Suspension_Schedule_L6_Price', '0.39'),
                  ('@Suspension_Schedule_L60_Price', '2.93'),
                  ('@Suspension_Schedule_L5_Price', '0.37'),
                  ('@Suspension_Schedule_LReg_Price', '9.7')]),
     OrderedDict([('@RegionID', 'TAS1'),
                  ('@DF', '2.3228759765625'),
                  ('@DemandForecast', '997.246337890625'),
                  ('@Suspension_Schedule_Energy_Price', '26.84'),
                  ('@Suspension_Schedule_R6_Price', '9.46'),
                  ('@Suspension_Schedule_R60_Price', '8.99'),
                  ('@Suspension_Schedule_R5_Price', '0.91'),
                  ('@Suspension_Schedule_RReg_Price', '11.16'),
                  ('@Suspension_Schedule_L6_Price', '1.27'),
                  ('@Suspension_Schedule_L60_Price', '2.21'),
                  ('@Suspension_Schedule_L5_Price', '0.35'),
                  ('@Suspension_Schedule_LReg_Price', '9.15')]),
     OrderedDict([('@RegionID', 'VIC1'),
                  ('@DF', '49.33447265625'),
                  ('@DemandForecast', '4157.650390625'),
                  ('@Suspension_Schedule_Energy_Price', '22.54'),
                  ('@Suspension_Schedule_R6_Price', '1.01'),
                  ('@Suspension_Schedule_R60_Price', '1.41'),
                  ('@Suspension_Schedule_R5_Price', '0.76'),
                  ('@Suspension_Schedule_RReg_Price', '11.18'),
                  ('@Suspension_Schedule_L6_Price', '0.45'),
                  ('@Suspension_Schedule_L60_Price', '1.19'),
                  ('@Suspension_Schedule_L5_Price', '0.39'),
                  ('@Suspension_Schedule_LReg_Price', '9.72')])]



### Submitting a modified case file
The same steps outlined in the [previous tutorial](/nemde-api-docs/tutorials/running-a-model) can be followed to submit a job using the modified case file. An option can also be included to return the (augmented) case file.


```python
def submit_casefile(base_url, casefile):
    """Submit case file to job queue"""

    # Construct request body and URL
    body = {
        'casefile': casefile,
        'options': {
            'return_casefile': True
        }
    }

    url = base_url + 'jobs/create'
    
    # Send job to queue and return job meta data
    response = requests.post(url=url, json=body)
    
    return response.json()


# Submit job and inspect job info
job_info = submit_casefile(base_url=base_url,casefile=casefile)
job_info
```




    {'job_id': '8b8a7dc5-6048-44c8-91fb-022b3b28cc53',
     'created_at': '2021-08-07T13:51:17.444858Z',
     'enqueued_at': '2021-08-07T13:51:17.578846Z',
     'timeout': 180,
     'status': 'queued',
     'label': None}



Once the model has finished solving we can access the results.


```python
def get_job_results(base_url, job_id):
    """Extract job results from queue"""
    
    url = base_url + f'jobs/{job_id}/results'   
    response = requests.get(url=url)
    
    return response.json()


# Get job results from the queue
job_id = job_info.get('job_id')
job_results = get_job_results(base_url=base_url, job_id=job_id)
```

The `results` key returns two nested objects: `input` corresponds to the case file submitted to the queue, while `output` is the solution returned by the worker.


```python
job_results.get('results').keys()
```




    dict_keys(['input', 'output'])



We can verify the updated case file was passed to the worker by inspecting the value corresponding to `input`.


```python
(job_results.get('results').get('input')
 .get('NEMSPDCaseFile').get('NemSpdInputs')
 .get('PeriodCollection').get('Period')
 .get('RegionPeriodCollection').get('RegionPeriod'))
```




    [{'@RegionID': 'NSW1',
      '@DF': '50.11376953125',
      '@DemandForecast': '6575.22802734375',
      '@Suspension_Schedule_Energy_Price': '34.66',
      '@Suspension_Schedule_R6_Price': '1.01',
      '@Suspension_Schedule_R60_Price': '1.41',
      '@Suspension_Schedule_R5_Price': '0.76',
      '@Suspension_Schedule_RReg_Price': '11.18',
      '@Suspension_Schedule_L6_Price': '0.45',
      '@Suspension_Schedule_L60_Price': '1.19',
      '@Suspension_Schedule_L5_Price': '0.39',
      '@Suspension_Schedule_LReg_Price': '9.72'},
     {'@RegionID': 'QLD1',
      '@DF': '1.39823298286458',
      '@DemandForecast': '5362.80249',
      '@Suspension_Schedule_Energy_Price': '35.01',
      '@Suspension_Schedule_R6_Price': '1.01',
      '@Suspension_Schedule_R60_Price': '1.41',
      '@Suspension_Schedule_R5_Price': '0.76',
      '@Suspension_Schedule_RReg_Price': '11.18',
      '@Suspension_Schedule_L6_Price': '0.45',
      '@Suspension_Schedule_L60_Price': '1.19',
      '@Suspension_Schedule_L5_Price': '0.39',
      '@Suspension_Schedule_LReg_Price': '9.72'},
     {'@RegionID': 'SA1',
      '@DF': 20,
      '@DemandForecast': '1075.27025222778',
      '@Suspension_Schedule_Energy_Price': '32.23',
      '@Suspension_Schedule_R6_Price': '1.01',
      '@Suspension_Schedule_R60_Price': '1.41',
      '@Suspension_Schedule_R5_Price': '0.76',
      '@Suspension_Schedule_RReg_Price': '11.18',
      '@Suspension_Schedule_L6_Price': '0.39',
      '@Suspension_Schedule_L60_Price': '2.93',
      '@Suspension_Schedule_L5_Price': '0.37',
      '@Suspension_Schedule_LReg_Price': '9.7'},
     {'@RegionID': 'TAS1',
      '@DF': '2.3228759765625',
      '@DemandForecast': '997.246337890625',
      '@Suspension_Schedule_Energy_Price': '26.84',
      '@Suspension_Schedule_R6_Price': '9.46',
      '@Suspension_Schedule_R60_Price': '8.99',
      '@Suspension_Schedule_R5_Price': '0.91',
      '@Suspension_Schedule_RReg_Price': '11.16',
      '@Suspension_Schedule_L6_Price': '1.27',
      '@Suspension_Schedule_L60_Price': '2.21',
      '@Suspension_Schedule_L5_Price': '0.35',
      '@Suspension_Schedule_LReg_Price': '9.15'},
     {'@RegionID': 'VIC1',
      '@DF': '49.33447265625',
      '@DemandForecast': '4157.650390625',
      '@Suspension_Schedule_Energy_Price': '22.54',
      '@Suspension_Schedule_R6_Price': '1.01',
      '@Suspension_Schedule_R60_Price': '1.41',
      '@Suspension_Schedule_R5_Price': '0.76',
      '@Suspension_Schedule_RReg_Price': '11.18',
      '@Suspension_Schedule_L6_Price': '0.45',
      '@Suspension_Schedule_L60_Price': '1.19',
      '@Suspension_Schedule_L5_Price': '0.39',
      '@Suspension_Schedule_LReg_Price': '9.72'}]



We can see our update is reflected in the case file consumed by the worker.

## Method 2 - Using JSON path syntax

While the previous method is quite intuitive, it is not very robust - it's to lose track of which values have been updated when using loops. An alternative is to search and update the case file dictionary using JSON path syntax. Rather than loop through a list, expressions can be specified to find and update specific elements. See [jsonpath-ng](https://github.com/h2non/jsonpath-ng) to learn more about the syntax.

An expression targeting the `@DF` parameter for South Australia can be formulated as follows:


```python
# Path to South Australia region period parameters
expression = ("NEMSPDCaseFile \
              .NemSpdInputs \
              .PeriodCollection \
              .Period \
              .RegionPeriodCollection \
              .RegionPeriod[?(@RegionID=='SA1')] \
              .@DF")
```

Note this expression corresponds to the path outlined on the [parameter reference page](/nemde-api-docs/parameter-reference/#demand-forecast). When seeking to update parameters users can consult this document to find paths corresponding to parameters of interest. 

The following functions can be used to get and update parameters using a JSON path expression.


```python
def get_casefile_parameter(casefile, expression):
    """
    Get parameter given a case file and JSON path expression
    
    Parameters
    ----------
    casefile : dict
        System parameters
    
    expression : str
        JSON path expression to value or object that should be
        extracted
        
    Returns
    -------
    Value corresponding to JSON path expression.    
    """

    jsonpath_expr = parse(expression)
    values = [match.value for match in jsonpath_expr.find(casefile)]
    
    # Check only one match found
    if len(values) != 1:
        raise Exception(f'Expected 1 match, encountered {len(values)}')
        
    return values[0]


def update_casefile_parameter(casefile, expression, new_value):
    """
    Update case file parameter
    
    Parameters
    ----------
    casefile : dict
        System parameters
    
    expression : str
        JSON path to value or object that should be updated
    
    new_value : str, float, or int
        New value for parameter
    
    Returns
    -------
    casefile : dict
        Updated case file
    """

    jsonpath_expr = parse(expression)
    values = [match.value for match in jsonpath_expr.find(casefile)]
    
    # Check only one match found
    if len(values) != 1:
        raise Exception(f'Expected 1 match, encountered {len(values)}')
    
    # Update case file
    jsonpath_expr.update(casefile, new_value)
    
    return casefile
```

Let's get the value of South Australia's `@DF` parameter.


```python
get_casefile_parameter(casefile=casefile, expression=expression)
```




    20



Similarly, we can update values given an expression.


```python
# Update @DF parameter for SA1 - set @DF = 60
casefile = update_casefile_parameter(casefile=casefile, expression=expression, new_value=60)

# Check the value has been updated
get_casefile_parameter(casefile=casefile, expression=expression)
```




    60



## Summary
We've explored two ways to update case file parameters. The first method can be useful if seeking to explore a case file's structure, and augment parameters in an ad hoc manner. The second method is more precise in its ability to target specific parameters within a case file as it avoids the use of loops. The following tutorials will build upon these tools when conducting scenario analyses using the NEMDE API.
