# Converting a case file

Historical NEMDE case files are easily converted into a format that can be consumed by the NEMDE API by using the following code snippet.


```python
import xmltodict


def convert_casefile(path_to_file):
    """Load a historical NEMDE case file and convert it to a dict"""
    
    # Read case file contents
    with open(path_to_file, 'r') as f:
        casefile = f.read()
    
    # Force these nodes to always return lists
    force_list = ('Trade', 'TradeTypePriceStructure',)

    return xmltodict.parse(casefile, force_list=force_list)


# Example NEMDE case file
path_to_file = '../../data/NEMSPDOutputs_2021040100100.loaded'

# Case file loaded as a Python dictionary
converted_casefile = convert_casefile(path_to_file=path_to_file)

converted_casefile.get('NEMSPDCaseFile').keys()
```




    odict_keys(['NemSpdInputs', 'NemSpdOutputs', 'SolutionAnalysis'])



Note that historical case files have a `.loaded` suffix, with data within these files organised in XML format.
