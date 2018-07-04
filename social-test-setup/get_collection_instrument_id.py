import os

import requests

from config import Config

COLLECTION_INSTRUMENT_SERVICE_URL = os.getenv('COLLECTION_INSTRUMENT_SERVICE_URL')
COLLECTION_EXERCISE_ID = os.getenv('COLLECTION_EXERCISE_ID')

if __name__ == '__main__':
    response = requests.get(f'{COLLECTION_INSTRUMENT_SERVICE_URL}'
                            f'collection-instrument-api/1.0.2/collectioninstrument?searchString='
                            f'{{"collection_exercise":"{COLLECTION_EXERCISE_ID}"}}',
                            auth=Config.AUTH)
    response.raise_for_status()
    print(f'COLLECTION_INSTRUMENT_ID={response.json()[0]["id"]}')
