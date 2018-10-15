import os

import requests

from config.setup_config import Config


def upload_ci(survey_id: str, collection_exercise_id: str):
    querystring = {'survey_id': survey_id,
                   'classifiers': f'{{"collection_exercise":"{collection_exercise_id}",'
                                  f'"eq_id":"lms",'
                                  f'"form_type":"2"}}'}

    upload_response = requests.post(f'{Config.COLLECTION_INSTRUMENT_SERVICE_URL}'
                                    f'/collection-instrument-api/1.0.2/upload',
                                    auth=Config.AUTH,
                                    params=querystring)
    upload_response.raise_for_status()
    print(upload_response.text)


if __name__ == '__main__':
    upload_ci(os.getenv('SURVEY_ID'), os.getenv('COLLECTION_EXERCISE_ID'))
