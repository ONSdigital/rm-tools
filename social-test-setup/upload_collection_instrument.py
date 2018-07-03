import requests

url = "http://localhost:8002/collection-instrument-api/1.0.2/upload"
collex_id = 'b025ca8d-0392-4b14-ad65-81ef0d52ecdf'
survey_id = '3471e953-3dac-4364-acda-de6da50ad05c'

querystring = {"survey_id": survey_id,
               "classifiers": f'{{"collection_exercise":"{collex_id}"}}'}

headers = {
    'Content-Type': "application/json",
    'Authorization': "Basic YWRtaW46c2VjcmV0",
    'Cache-Control': "no-cache"
    }

response = requests.request("POST", url, headers=headers, params=querystring)

print(response.text)
