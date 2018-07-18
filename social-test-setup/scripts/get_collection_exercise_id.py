import os

import requests

from config.setup_config import Config


def get_collex_id() -> str:
    global response
    response = requests.get(f'{Config.COLLECTION_EXERCISE_SERVICE_URL}'
                            f'/collectionexercises/1/survey/999',
                            auth=Config.AUTH)
    response.raise_for_status()
    collex_id = response.json()["id"]
    print(f'COLLECTION_EXERCISE_ID={collex_id}')
    return collex_id


if __name__ == '__main__':
    get_collex_id()
