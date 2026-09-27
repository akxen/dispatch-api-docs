# Dispatch API Documentation

The Dispatch API allows users to interact with a mathematical program that approximates Australia's National Electricity Market Dispatch Engine (NEMDE). The model is formulated as a single period economic dispatch problem that seeks to dispatch generators and loads such that demand is met at the lowest cost while respecting unit, network, and system constraints. The source code is available at [github.com/akxen/nemde](https://github.com/akxen/nemde).

The API can be used to investigate relationships between system parameters and dispatch outcomes, with possible applications including ex-post scenario and sensitivity analyses, or the tool's integration within forecasting frameworks.

> **This is not AEMO's model.** It is a best-effort reconstruction built from publicly available NEMDE documentation and from behaviour observed in published case files. It does not use AEMO's source code or exact formulation, it will not match NEMDE exactly, and it is provided with no warranty of any kind.

## Features and known limitations

The model used to approximate the NEMDE includes the following components:

- energy and FCAS offers from generators, loads, bidirectional units (e.g. batteries), and wholesale demand response units;
- 1-second, 6-second, 60-second, and 5-minute contingency FCAS, and regulation FCAS;
- market network service provider (MNSP) offers;
- interconnector loss models with SOS2 constraints;
- MNSP loss factors (Basslink);
- generic constraints;
- FCAS constraints, including AGC limits;
- effective ramp rates that account for SCADA ramp rates;
- two pass solution algorithm and inflexibility profiles for fast-start units;
- tie-breaking model for price-tied energy offers.

Users should note the Dispatch API is subject to some important limitations:

- FCAS prices are not reported;
- generic constraint right-hand side (RHS) values are obtained from historical NEMDE solutions rather than computed from SCADA values, so case files must include the NEMDE solution (`NemSpdOutputs`);
- intervention pricing runs are not supported;
- prices are not adjusted to the market price floor or cap if these thresholds are exceeded;
- constraint relaxation algorithms are not implemented;
- energy storage limits for bidirectional units are not enforced (AEMO applies these in pre-dispatch only).

## How it works

The Dispatch API is a web service that you run yourself, either with Docker or directly with Python. Users first prepare parameters describing the National Electricity Market's state in the form of a case file. Parameters include:

- offers and bids made by generators and loads;
- initial conditions for units, interconnectors, and regions;
- interconnector loss model factors;
- generic constraint terms.

See the [parameter reference page](/dispatch-api-docs/parameter-reference) for more details regarding the data that can be submitted via the API.

The case file is sent to the API in the body of a request. The API formulates and solves the model, then returns the solution in its response. There is no queue: each request waits for its own solution, which usually takes well under a minute. Case files can be sent as the original NEMDE XML (`.loaded` or `.xml` files) or as JSON.

### Running the API

The only prerequisite is [Docker](https://www.docker.com/). From a copy of the [nemde repository](https://github.com/akxen/nemde):

```bash
docker build --build-arg GIT_SHA=$(git rev-parse HEAD) -t nemde .
docker run -p 8000:8000 nemde
```

The API is then available at `http://localhost:8000`. Opening that address in a browser shows a page where you can upload a case file and view the result as a report. See the repository's README for running the API without Docker.

### Endpoints

| Route | Description |
| :---- | :---------- |
| `GET /` | Upload page for running a case file from the browser |
| `POST /solve` | Solves the case file and returns the dispatch solution |
| `POST /backtest` | Solves the case file, then compares the result with the NEMDE solution contained in the same file |

Set the `Content-Type` header to match the request body: `application/xml` for an XML case file, or `application/json` for a case file converted to JSON. Send `Accept: text/html` to receive an HTML report; otherwise the response is JSON.

`/solve` returns the solution as JSON with the following keys: `CaseSolution`, `PeriodSolution`, `RegionSolution`, `TraderSolution`, `InterconnectorSolution`, `ConstraintSolution`, `ObjectiveBreakdown`, and `SolverInfo`. The first six follow the structure of the `NemSpdOutputs` section of a NEMDE case file.

`/backtest` returns a pass/fail summary. Use `/solve` for any case file you have modified, since NEMDE's published solution describes the original case file rather than your modified one. The pass/fail thresholds can be adjusted with query parameters:

| Parameter | Default | Description |
| :-------- | :------ | :---------- |
| `tolerance` | `0.1` | Largest allowed error on dispatch targets and interconnector flows (MW) |
| `obj_tolerance` | `0.05` | Largest allowed relative error on the objective value (0.05 = 5%) |
| `energy_price_tolerance` | `1.0` | Largest allowed energy price error ($/MWh) |

For example, to solve a historical case file with Python:

```python
import requests

with open('NEMSPDOutputs_2024070100100.loaded', 'rb') as f:
    casefile = f.read()

response = requests.post(
    'http://localhost:8000/solve',
    data=casefile,
    headers={'Content-Type': 'application/xml'},
)
solution = response.json()

solution['RegionSolution']
```

To compare the same case file against NEMDE's solution, send it to `/backtest` instead:

```python
response = requests.post(
    'http://localhost:8000/backtest',
    data=casefile,
    headers={'Content-Type': 'application/xml'},
)
response.json()['passed']
```

Historical NEMDE case files can be downloaded from AEMO's [NEMWeb archive](https://nemweb.com.au/Data_Archive/Wholesale_Electricity/NEMDE/).

## Getting started
### Tutorials
The tutorials section gives an overview of the Dispatch API's features and provides examples on how to setup scenario analyses and associated workflows. The [Running a Model](/dispatch-api-docs/tutorials/running-a-model) tutorial is the recommended starting point for new users.

> The tutorials were written for an earlier, hosted version of the Dispatch API that used a job queue. They are being updated for the current version. Until then, replace the steps that submit a job and poll for its results with a single request to `/solve`, as shown above.

### Case file reference
The [parameter reference page](/dispatch-api-docs/parameter-reference) shows the parameters that can be meaningfully updated when modifying or constructing case files.

### Model validation
The [model validation section](/dispatch-api-docs/model-validation/202011/model-validation) compares solutions from an earlier version of the Dispatch API with results obtained from NEMDE. To check the current version against NEMDE for any interval, send that interval's case file to `/backtest`.

### Case studies
See potential applications of the Dispatch API via [case studies](/dispatch-api-docs/case-studies/case-studies).
