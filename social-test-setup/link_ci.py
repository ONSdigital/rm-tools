import os

import requests

from config import Config

COLLECTION_INSTRUMENT_ID = os.getenv('COLLECTION_INSTRUMENT_ID')
COLLECTION_EXERCISE_ID = os.getenv('COLLECTION_EXERCISE_ID')
SURVEY_ID = os.getenv('SURVEY_ID')
COLLECTION_INSTRUMENT_SERVICE_URL = os.getenv('COLLECTION_INSTRUMENT_SERVICE_URL')

if __name__ == '__main__':
    link_response = requests.post(url=f'{COLLECTION_INSTRUMENT_SERVICE_URL}'
                                      f'collection-instrument-api/1.0.2/link-exercise/'
                                      f'{COLLECTION_INSTRUMENT_ID}/'
                                      f'{COLLECTION_EXERCISE_ID}',
                                  auth=Config.AUTH)

    link_response.raise_for_status()
    print(link_response.status_code)
    print(link_response.content.decode())
