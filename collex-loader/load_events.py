#!/usr/bin/python
import argparse
from functools import partial
import json
import requests
from file_processing import process_files
from datetime import datetime, timezone
import re

# Ignore these as they are the key for the collection exercise and don't represent event data
ignore_columns = [ 'surveyRef', 'exerciseRef' ]

def parse_args():
    parser = argparse.ArgumentParser(description='Load collection exercise event CSV.')
    parser.add_argument("config", help="Configuration file")
    return parser.parse_args() 

def post_event(collex_id, event_tag, date, url, user, password):
    post_data = get_post_data(event_tag, date)

    response = requests.post(url.format(id=collex_id), json=post_data, auth=(user, password))

    status_code = response.status_code
    detail_text = response.text if status_code != 201 else ''

    print("{} <= {} ({})".format(status_code, post_data, detail_text))

def reformat_date(date):
    if len(date) == 5:
        # Looks like the dates are zero padded unless the day number is < 10 in which case the 0 is missing
        # so if we have a 5 digit date we can assume it's a date in the first 9 days of a month and prefixing
        # a zero will give us the correct value
        date = '0' + date

    try:
        raw = datetime.strptime(date, '%d%m%y')
        raw = raw.replace(tzinfo=timezone.utc)
    except ValueError:
        print("Failed to parse {}".format(date))
        raise

    time_str = raw.isoformat(timespec='milliseconds')
    # WATCH OUT: this removes the last : from a valid ISO8601 date string to form another
    # valid ISO8601 date string that can be easily deserialised by Jackson in the Java service
    clean_str = re.sub(r'(.*):', '\\1', time_str)

    return clean_str

def get_post_data(event_tag, date_str):
    post_data = dict()
    post_data['tag'] = event_tag
    post_data['timestamp'] = reformat_date(date_str)

    return post_data

def dump_event(collex_id, event_tag, date_str):
    post_data = get_post_data(event_tag, date_str)

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

    try:
        if data['error']:
            # There are 2 different formats of the data depending on what kind of error it is, so just dump it out as json
            raise ValueError(json.dumps(data))
    except KeyError:
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
