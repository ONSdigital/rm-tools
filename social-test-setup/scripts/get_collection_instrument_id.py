import os

import requests

from config.setup_config import Config


def get_collection_instrument_id(collection_exercise_id: str) -> str:
    global response
    response = requests.get(f'{Config.COLLECTION_INSTRUMENT_SERVICE_URL}'
                            f'/collection-instrument-api/1.0.2/collectioninstrument?searchString='
                            f'{{"collection_exercise":"{collection_exercise_id}"}}',
                            auth=Config.AUTH)
    response.raise_for_status()
    collection_instrument_id = response.json()[0]['id']
    print(f'COLLECTION_INSTRUMENT_ID={collection_instrument_id}')
    return collection_instrument_id


if __name__ == '__main__':
    get_collection_instrument_id(os.getenv('COLLECTION_EXERCISE_ID'))
