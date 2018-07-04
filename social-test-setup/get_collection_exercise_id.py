import os

import requests

from config import Config

COLLECTION_EXERCISE_SERVICE_URL = os.getenv('COLLECTION_EXERCISE_SERVICE_URL')

if __name__ == '__main__':
    response = requests.get(f'{COLLECTION_EXERCISE_SERVICE_URL}collectionexercises/1/survey/999',
                            auth=Config.AUTH)
    response.raise_for_status()
    print(f'COLLECTION_EXERCISE_ID={response.json()["id"]}')
