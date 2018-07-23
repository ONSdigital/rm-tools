import os
from pprint import pprint

import requests

from config.setup_config import Config


def link_sample(collection_exercise_id: str, sample_summary_id: str):
    sample_summaries = {'sampleSummaryIds': [sample_summary_id]}
    link_collex_response = requests.put(
        url=f'{Config.COLLECTION_EXERCISE_SERVICE_URL}'
            f'/collectionexercises/link/{collection_exercise_id}',
        json=sample_summaries,
        auth=Config.AUTH)
    link_collex_response.raise_for_status()
    print(link_collex_response.status_code)
    pprint(link_collex_response.json())


if __name__ == '__main__':
    link_sample(os.getenv('COLLECTION_EXERCISE_ID'), os.getenv('SAMPLE_SUMMARY_ID'))
