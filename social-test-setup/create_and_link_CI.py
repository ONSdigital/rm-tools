import json
from pprint import pprint

import requests
from requests.auth import HTTPBasicAuth

ci_url = 'http://localhost:8002/'
user = 'admin'
password = 'secret'

collex_id = '86857032-c4f3-4eec-999d-04fe6d45e9d5'
survey_id = 'ee8c5c68-7eb4-4ead-8a37-ef33689f0a58'
ci_id = '6aa18898-845f-4693-98ec-e6e7bba8912d'

if __name__ == '__main__':
    create_ci = requests.put(url=f'{ci_url}collection-instrument-api/1.0.2/upload/{collex_id}',
                                        auth=HTTPBasicAuth(username=user, password=password))
    link_collex_to_ce = requests.put(url=f'{ci_url}collection-instrument-api/1.0.2/link/{ci_id}/{collex_id}',
                                        auth=HTTPBasicAuth(username=user, password=password))
    pprint(json.loads(link_collex_to_ce.content))
