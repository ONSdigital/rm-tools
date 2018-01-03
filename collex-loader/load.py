import csv
import json
import argparse
import requests
from functools import partial

def parse_args():
    parser = argparse.ArgumentParser(description='Load collection exercise CSV.')
    parser.add_argument("config", help="Configuration file")
    return parser.parse_args() 

def map_columns(column_mappings, row):
    new_row = dict()
    for key, value in row.items():
        if key and value:
            new_row[column_mappings[key] if column_mappings[key] else key] = value
    return new_row

def post_collex(data, url, user, password):
    response = requests.post(url, json=data, auth=(user, password))

    status_code = response.status_code
    detail_text = response.text if status_code != 201 else ''

    print("%s <= %s (%s)" % (status_code, data, detail_text))

def dump_collex(data):
    survey_id = data['surveyRef']
    period = data['exerciseRef']
    if survey_id and period:
        filename = "%s-%s.json" % (survey_id, period)
        with open(filename, 'w') as fo:
            json.dump(data, fo)

def clean_row(row):
    row['name'] = row['name'][:20]

    return row
        
def process_file(filename, row_handler):
    with open(filename) as fp:
        reader = csv.DictReader(fp)
        for row in reader:
            new_row = map_columns(column_mappings, row)

            if new_row:
                row_handler(data=clean_row(new_row))

args = parse_args()
print("Config filename: %s" % args.config)
config = json.load(open(args.config))
input_file = config['inputFile']
print("Input filename: %s" % input_file)
column_mappings = config['columnMappings']
api_url = config['api']['url']
print ("API URL: %s" % api_url)
row_handler = dump_collex if config['dryRun'] else partial(post_collex, url=api_url, user=config['api']['user'], password=config['api']['password'])

result = process_file(input_file, row_handler)
