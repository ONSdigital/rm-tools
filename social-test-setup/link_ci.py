import requests
from requests.auth import HTTPBasicAuth

ci_url = 'http://localhost:8002/'
user = 'admin'
password = 'secret'

collex_id = 'b025ca8d-0392-4b14-ad65-81ef0d52ecdf'
survey_id = '3471e953-3dac-4364-acda-de6da50ad05c'
ci_id = 'facf940f-a376-4fdc-b308-1117710aaa9e'

if __name__ == '__main__':
    link_collex_to_ce = requests.post(url=f'{ci_url}collection-instrument-api/1.0.2/link-exercise/{ci_id}/{collex_id}',
                                      auth=HTTPBasicAuth(username=user, password=password))

    print(link_collex_to_ce.status_code)
    print(link_collex_to_ce.content.decode())
