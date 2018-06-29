import json
from pprint import pprint
import sys
from time import sleep

import requests
from requests.auth import HTTPBasicAuth

url = 'http://localhost:8125/'
filepath = 'data/test-1-sample.csv'
user = 'admin'
password = 'secret'
max_retries = 10

with open(filepath, 'rb') as fp:
    files = {'file': fp.read()}

if __name__ == '__main__':
    sample_upload_response = requests.post(f'{url}samples/SOCIAL/fileupload',
                                           files=files,
                                           auth=HTTPBasicAuth(username=user, password=password))

    sample_upload_response.raise_for_status()
    sample_upload_response = json.loads(sample_upload_response.content)

    if sample_upload_response['state'] == 'FAILED':
        print(sample_upload_response['notes'])
        sys.exit(1)

    pprint(sample_upload_response)
    print('Sample uploaded, polling for state change to "ACTIVE"')

    sample_summary_id = sample_upload_response['id']

    for retry in range(max_retries):
        sample_summary_response = requests.get(f'{url}samples/samplesummary/{sample_summary_id}',
                                               auth=HTTPBasicAuth(username=user, password=password))

        sample_summary_response.raise_for_status()
        summary = json.loads(sample_summary_response.content)

        if summary['state'] == 'ACTIVE':
            pprint(json.loads(sample_summary_response.content))
            break

        sleep(0.5)
    else:
        print(f'Max retries reached ({max_retries}), no successful response')
        sys.exit(1)

    print("Sample successfully ingested!")
