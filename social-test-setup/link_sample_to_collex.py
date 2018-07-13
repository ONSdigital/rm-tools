import os
from pprint import pprint

import requests

from config import Config

COLLECTION_EXERCISE_URL = os.getenv('COLLECTION_EXERCISE_SERVICE_URL')
COLLECTION_EXERCISE_ID = os.getenv('COLLECTION_EXERCISE_ID')
SAMPLE_SUMMARY_ID = os.getenv('SAMPLE_SUMMARY_ID')

sample_summaries = {'sampleSummaryIds': [SAMPLE_SUMMARY_ID]}

if __name__ == '__main__':
    link_collex_response = requests.put(
        url=f'{COLLECTION_EXERCISE_URL}'
            f'/collectionexercises/link/{COLLECTION_EXERCISE_ID}',
        json=sample_summaries,
        auth=Config.AUTH)
    link_collex_response.raise_for_status()

    print(link_collex_response.status_code)
    pprint(link_collex_response.json())
