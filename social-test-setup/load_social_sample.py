import json
import os
from pprint import pprint
import sys
from time import sleep

import requests

from config import Config

MAX_RETRIES = 100

SAMPLE_SERVICE_URL = os.getenv('SAMPLE_SERVICE_URL')
SAMPLE_PATH = os.getenv('SAMPLE_PATH')

with open(SAMPLE_PATH, 'rb') as fp:
    files = {'file': fp.read()}

if __name__ == '__main__':
    sample_upload_response = requests.post(f'{SAMPLE_SERVICE_URL}'
                                           f'/samples/SOCIAL/fileupload',
                                           files=files,
                                           auth=Config.AUTH)

    sample_upload_response.raise_for_status()
    sample_upload_response = json.loads(sample_upload_response.content)

    if sample_upload_response['state'] == 'FAILED':
        print(sample_upload_response['notes'])
        sys.exit(1)

    pprint(sample_upload_response)
    print('Sample uploaded, polling for state change to "ACTIVE"')

    sample_summary_id = sample_upload_response['id']

    for retry in range(MAX_RETRIES):
        sample_summary_response = requests.get(f'{SAMPLE_SERVICE_URL}'
                                               f'/samples/samplesummary/{sample_summary_id}',
                                               auth=Config.AUTH)
        if sample_summary_response.status_code == 404:
            sleep(0.5)
            continue

        sample_summary_response.raise_for_status()
        summary = json.loads(sample_summary_response.content)

        if summary['state'] == 'ACTIVE':
            pprint(json.loads(sample_summary_response.content))

            break

        sleep(0.5)
    else:
        print(f'Max retries reached ({MAX_RETRIES}), no successful response')
        sys.exit(1)

    print("Sample successfully ingested!")
    print(f'SAMPLE_SUMMARY_ID={sample_summary_id}')
