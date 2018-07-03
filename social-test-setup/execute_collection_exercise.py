import requests
from requests.auth import HTTPBasicAuth

collex_id = 'b025ca8d-0392-4b14-ad65-81ef0d52ecdf'
url = 'http://localhost:8145/'
user = 'admin'
password = 'secret'

headers = {
    'Cache-Control': 'no-cache',
    'Postman-Token': '7bbe18e1-016c-4258-8a85-4d68f1150a82',
    }

response = requests.post(f'{url}collectionexerciseexecution/{collex_id}',
                         headers=headers,
                         auth=HTTPBasicAuth(username=user,
                                            password=password))

print(response.text)
