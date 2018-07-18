# Social Test One Setup Tools

A collection of scripts for creating and running the Online Household Study (alpha).

## Configuration
Some config variables are read from the environment or a `.env` file.
To run locally against the rasrm-docker-dev services use this initial config.

```dotenv
AUTH_USERNAME=admin
AUTH_PASSWORD=secret

SURVEY_SERVICE_URL=http://localhost:8080
COLLECTION_EXERCISE_SERVICE_URL=http://localhost:8145
SAMPLE_SERVICE_URL=http://localhost:8125
COLLECTION_INSTRUMENT_SERVICE_URL=http://localhost:8002
ACTION_SERVICE_URL=http://localhost:8151
```

## Social Test Setup


### Create the Survey (With Classifiers)
Run `make create-survey`

This will create the OHS Survey with `COLLECTION_EXERCISE` as the comms and instrument classifiers
If successful a `SURVEY_ID` value should be printed, add it to the env for the next steps.

### Create the Collection Exercise
Creating the collection exercise is done through the collex-loader tool.

Run `make create-collection-exercise`

This will generate the config file for the collex loader and run it, then get the ID's of the resources generated.
If successful a `COLLECTION_EXERCISE_ID` and `ACTION_PLAN_ID` value should be printed, add it to the env for the next steps.

### Add the Collection Exercise Events
Make sure the `COLLECTION_EXERCISE_ID` is set in the environment

Run `make create-collection-events`

This will generate the config file for the collex event loader and run it, then get the ID's of the resources generated.

### Load the Social Sample File
Set `SAMPLE_PATH` to the path to the sample file to load.

Run `make load-sample`

This will upload the sample to the sample service then poll it until the sample ingest finishes and the sample state
becomes `ACTIVE`.

If successful a `SAMPLE_SUMMARY_ID` value should be printed, add it to the env for the next steps.

### Link the Sample to the Collection Exercise
Having uploaded a sample and set the `SAMPLE_SUMMARY_ID` and `COLLECTION_EXERCISE_ID` in the env in previous steps,
run `make link-sample`

### Load the Collection Instrument
Ensure the `SURVEY_ID` and `COLLECTION_EXERCISE_ID` are set to the values from previous steps.

Run `make load-ci`

If successful a `COLLECTION_INSTRUMENT_ID` will be printed add it to the env for the next steps.

### Link the Collection Instrument
Ensure the `COLLECTION_INSTRUMENT_ID` is set from the last step.

Run `make link-ci`

### Creating the Action Rules
Ensure the `ACTION_PLAN_ID` is set to the value output when creating the collection exercise.

Run `make create-action-rules`

### Executing the Collection Exercise
After running all other set up steps, ensure the `COLLECTION_EXERCISE_ID` is set.

Run `make execute-collection-exercise`