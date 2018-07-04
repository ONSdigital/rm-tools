import os

import requests

from config import Config

COLLECTION_INSTRUMENT_SERVICE_URL = os.getenv('COLLECTION_INSTRUMENT_SERVICE_URL')
COLLECTION_EXERCISE_ID = os.getenv('COLLECTION_EXERCISE_ID')
SURVEY_ID = os.getenv('SURVEY_ID')

querystring = {"survey_id": SURVEY_ID,
               "classifiers": f'{{"collection_exercise":"{COLLECTION_EXERCISE_ID}"}}'}

if __name__ == '__main__':
    upload_response = requests.post(f'{COLLECTION_INSTRUMENT_SERVICE_URL}collection-instrument-api/1.0.2/upload',
                                    auth=Config.AUTH,
                                    params=querystring)
    upload_response.raise_for_status()
    print(upload_response.text)
