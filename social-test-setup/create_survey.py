import json
import os

import requests

from config import Config

SURVEY_SERVICE_URL = os.getenv('SURVEY_SERVICE_URL')
SURVEY_PATH = os.getenv('SURVEY_PATH')

if __name__ == '__main__':
    survey = {
        'surveyRef': '999',
        'shortName': 'OHS',
        'longName': 'Online Household Study (alpha)',
        'legalBasisRef': 'Vol',
        'surveyType': 'Social'
    }

    surveys_response = requests.post(url=f'{SURVEY_SERVICE_URL}/surveys',
                                     json=survey,
                                     auth=Config.AUTH)
    surveys_response.raise_for_status()

    print(f'Survey service response: {surveys_response.status_code}, {surveys_response.text}')
    print(f'SURVEY_ID={json.loads(surveys_response.content)["id"]}')
