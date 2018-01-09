collex-loader
=============

The collex-loader is a Python script for loading the [data as supplied by the business](data/CE_Details_for_loading_into_RM.csv) into the collection exercise service using JSON POST requests.

example usage
-------------

```
python load.py config/app-config.json
```

configuration
-------------

The loader script requires a JSON configuration file to be supplied as the first command line parameter.  JSON was chosen for the configuration in place of YML as it requires no additional libraries to parse. There is [an example of the configuration file](config/app-config.json), repeated here for clarity.

```
{
    "inputFile": "data/CE_Details_for_loading_into_RM.csv",
    "dryRun": false,
    "api":{
        "url": "http://localhost:8145/collectionexercises",
        "user": "admin",
        "password": "secret"
    },
    "columnMappings": {
        "Survey_Id": "surveyRef",
        "Survey_Name": "name",
        "Collection_Period": "exerciseRef",
        "Collection_Period_Label": "userDescription"
    }
}
```

| Config item    | Description |
| -----------    | ----------- |
| inputFile      | The CSV file containing the collection exercise data to load |
| dryRun         | A boolean to indicate whether this is a dry run or not - see section on Dry Runs below | 
| api/url        | The URL for the collection exercise service endpoint |
| api/user       | The the name of the basic auth user protecting the collection exercise service endpoint |
| api/password   | The the password of the basic auth user protecting the collection exercise service endpoint |
| columnMappings | A dictionary of column name mappings to apply to the rows in the CSV - key is CSV column name, value is the column as it should appear in the JSON output |

dry runs
--------

It is possible to get the loader to run in a test mode to examine the output it would produce. In order to do this, the dryRun flag in app-config.json should be set to true.  When this is set to true, instead of POSTing the JSON to the collection exercise service endpoint, the loader will dump it out to a file in the current directory with the following filename:

<survey_ref>-<exercise_ref>.json

For example, 134-201807.json
