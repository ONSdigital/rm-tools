#!/usr/bin/python
import argparse
from functools import partial
import json
import requests
from file_processing import process_files
import datetime

# Ignore these as they are the key for the collection exercise and don't represent event data
ignore_columns = [ 'surveyRef', 'exerciseRef' ]

def parse_args():
    parser = argparse.ArgumentParser(description='Load collection exercise event CSV.')
    parser.add_argument("config", help="Configuration file")
    return parser.parse_args() 

def post_event(collex_id, event_tag, date, url, user, password):
    post_data = dict()
    post_data['tag'] = event_tag
    post_data['timestamp'] = date
    response = requests.post(url.format(id=collex_id), json=post_data, auth=(user, password))

    status_code = response.status_code
    detail_text = response.text if status_code != 201 else ''

    print("{} <= {} ({})".format(status_code, post_data, detail_text))


def dump_event(collex_id, event_tag, date_str):
    post_data = dict()
    post_data['tag'] = event_tag
    post_data['timestamp'] = date_str
    filename = "%s-%s.json" % (event_tag, collex_id)
    with open(filename, 'w') as fo:
        json.dump(post_data, fo)

def row_handler(data, api_config, event_handler):
    collex_id = get_collection_exercise_uuid(data, api_config)
    for key, value in data.items():
        if not key in ignore_columns:
            event_handler(collex_id, key, value)

def get_collection_exercise_uuid(row, api_config):
    survey_ref = row['surveyRef']
    exercise_ref = row['exerciseRef']

    url = api_config['get-url'].format(exercise_ref=exercise_ref, survey_ref=survey_ref)
    response = requests.get(url, auth=(api_config['user'], api_config['password']))
    data = json.loads(response.text)

    return data['id']

if __name__ == '__main__':
    args = parse_args()

    print("Config filename: {}".format(args.config))
    config = json.load(open(args.config))

    input_files = config['inputFiles']
    print("Input filenames: {}".format(input_files))

    column_mappings = config['columnMappings']
    print("Column mappings: {}".format(column_mappings))

    dry_run = config['dryRun']
    print("Dry run: {}".format(dry_run))

    api_config = config['api']
    event_handler = dump_event if dry_run else partial(post_event, user=api_config['user'], password=api_config['password'], url=api_config['post-url'])
    row_handler = partial(row_handler, api_config=api_config, event_handler=event_handler)

    process_files(input_files, row_handler, column_mappings)
