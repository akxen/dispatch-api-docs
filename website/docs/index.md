# NEMDE API Documentation

The NEMDE API allows users to interact with a mathematical program that approximates Australia's National Electricity Market Dispatch Engine (NEMDE). The model is formulated as a single period economic dispatch problem that seeks to dispatch generators and loads such that demand is met at the lowest cost while respecting unit, network, and system constraints.

The API can be used to investigate relationships between system parameters and dispatch outcomes, with possible applications including ex-post scenario and sensitivity analyses, or the tool's integration within forecasting frameworks.

## Features and known limitations

The model used to approximate the NEMDE includes the following components:

- generator and load bids (FCAS and energy market);
- market network service provider (MNSP) bids;
- interconnector loss models with SOS2 constraints;
- Basslink loss model;
- generic constraints;
- FCAS constraints;
- two pass solution algorithm and inflexibility profiles for fast-start units;
- tie-breaking model for price-tied energy offers.

The [model validation section](/model-validation/202011/model-validation) describes the data-driven approach used to assess the NEMDE API's ability to emulate NEMDE outputs. Excellent correspondence is observed between solutions reported by the NEMDE API and those reported by the NEMDE. However, users should note the Dispatch API is subject to some important limitations:

- FCAS prices are not reported;
- generic constraint right-hand side (RHS) values are obtained from historical NEMDE solutions rather than computed from SCADA values;
- intervention pricing runs are not supported;
- prices are not adjusted to the market price floor or cap if these thresholds are exceeded;
- constraint relaxation algorithms are not implemented.

The above list represents known material limitations associated with the model. Work is underway to address each of these points, with updates likely to be incorporated within future versions of the NEMDE API.

## How it works

The NEMDE API allows users to interact with an online queue that coordinates the process of formulating and solving a model which approximates the NEMDE. Users first prepare parameters describing the National Electricity Market's state in the form of a case file. Parameters include:

- offers and bids made by generators and loads;
- initial conditions for units, interconnectors, and regions;
- interconnector loss model factors;
- generic constraint terms. 

See the [parameter reference page](/parameter-reference) for more details regarding the data that can be submitted via the API. 

Once a case file has been prepared, it can be submitted to an online queue via the NEMDE API. A pool of workers constantly monitor the queue for new case files. If a worker is idle when a case file enters the queue it will use the parameters submitted by the user to formulate and solve a model approximating the NEMDE. If all workers are occupied when the case file is submitted, the case file will 'wait' in the queue until a worker is available. Upon solving the model the worker posts its results back to queue, which can then be retrieved by the user. Results remain within the queue for a limited time (2 hours) at which point they are deleted.

The following diagram illustrates the workflow used when solving a model using the Dispatch API.

![queue model](/images/dispatch-api-site.png)

Multiple workers can monitor the queue simultaneously, allowing models to be solved in parallel. This capability allows large-scale scenario anlayses to be underaken.

## Getting started
### Tutorials
The tutorials section gives an overview of the NEMDE API's features and provides examples on how to setup scenario analyses and associated workflows. The [Running a Model](/tutorials/running-a-model) tutorial is the recommended starting point for new users. 

### Case file reference
The [parameter reference page](/parameter-reference) shows the parameters that can be meaningfully updated when modifying or constructing case files.

### Model validation
See how the solution returned by the NEMDE API compares to results obtained from NEMDE in the [model validation section](/model-validation/202011/model-validation).

### Case studies
See potential applications of the NEMDE API via [case studies](/case-studies/case-studies).
