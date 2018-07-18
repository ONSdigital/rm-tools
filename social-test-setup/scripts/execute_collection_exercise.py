import os

import requests

from config.setup_config import Config


def execute_collection_exercise(collection_exercise_id: str):
    execute_response = requests.post(f'{Config.COLLECTION_EXERCISE_SERVICE_URL}'
                                     f'/collectionexerciseexecution/'
                                     f'{collection_exercise_id}',
                                     auth=Config.AUTH)
    execute_response.raise_for_status()
    print(execute_response.text)
    print("Successfully executed collection exercise")


if __name__ == '__main__':
    execute_collection_exercise(os.getenv('COLLECTION_EXERCISE_ID'))
