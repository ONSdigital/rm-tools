import os

import requests

from config.setup_config import Config


def link_ci(collection_exercise_id: str, collection_instrument_id: str):
    link_response = requests.post(url=f'{Config.COLLECTION_INSTRUMENT_SERVICE_URL}'
                                      f'/collection-instrument-api/1.0.2/link-exercise/'
                                      f'{collection_instrument_id}/'
                                      f'{collection_exercise_id}',
                                  auth=Config.AUTH)
    link_response.raise_for_status()
    print(link_response.status_code)
    print(link_response.content.decode())


if __name__ == '__main__':
    link_ci(os.getenv('COLLECTION_EXERCISE_ID'), os.getenv('COLLECTION_INSTRUMENT_ID'))
