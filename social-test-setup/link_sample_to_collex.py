import json
from pprint import pprint

import requests
from requests.auth import HTTPBasicAuth

collex_url = 'http://localhost:8145/'
user = 'admin'
password = 'secret'

collex_id = 'b025ca8d-0392-4b14-ad65-81ef0d52ecdf'
sample_summary_id = '36b1baa6-cdb0-4b7b-b321-a794cfde69fb'

sample_summarys = {'sampleSummaryIds': [sample_summary_id]}

if __name__ == '__main__':
    link_collex_response = requests.put(url=f'{collex_url}collectionexercises/link/{collex_id}',
                                        json=sample_summarys,
                                        auth=HTTPBasicAuth(username=user, password=password))
    print(link_collex_response.status_code)
    pprint(json.loads(link_collex_response.content))
