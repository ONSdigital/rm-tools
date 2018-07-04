import os

import requests

from config import Config

COLLECTION_EXERCISE_ID = os.getenv('COLLECTION_EXERCISE_ID')
COLLECTION_EXERCISE_SERVICE_URL = os.getenv('COLLECTION_EXERCISE_SERVICE_URL')

if __name__ == '__main__':
    execute_response = requests.post(f'{COLLECTION_EXERCISE_SERVICE_URL}'
                                     f'collectionexerciseexecution/'
                                     f'{COLLECTION_EXERCISE_ID}',
                                     auth=Config.AUTH)

    execute_response.raise_for_status()

    print(execute_response.text)
