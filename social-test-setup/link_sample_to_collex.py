import json
from pprint import pprint

import requests
from requests.auth import HTTPBasicAuth

collex_url = 'http://localhost:8145/'
user = 'admin'
password = 'secret'

collex_id = '86857032-c4f3-4eec-999d-04fe6d45e9d5'
sample_summary_id = '39123dfd-26ab-430a-a2d3-473057fd3cda'

sample_summarys = {'sampleSummaryIds': [sample_summary_id]}

if __name__ == '__main__':
    link_collex_response = requests.put(url=f'{collex_url}collectionexercises/link/{collex_id}',
                                        json=sample_summarys,
                                        auth=HTTPBasicAuth(username=user, password=password))
    pprint(json.loads(link_collex_response.content))
