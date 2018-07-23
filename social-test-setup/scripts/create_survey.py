import json

import requests

from config.setup_config import Config


def create_survey() -> str:
    survey = {
        'surveyRef': '999',
        'shortName': 'OHS',
        'longName': 'Online Household Study (Alpha)',
        'legalBasisRef': 'Vol',
        'surveyType': 'Social'
    }
    surveys_response = requests.post(url=f'{Config.SURVEY_SERVICE_URL}/surveys',
                                     json=survey,
                                     auth=Config.AUTH)
    if surveys_response.status_code == 409:
        print(f'Survey already exists, getting ID')
        get_survey_response = requests.get(url=f'{Config.SURVEY_SERVICE_URL}/surveys/shortname/{survey["shortName"]}',
                                           auth=Config.AUTH)
        get_survey_response.raise_for_status()
        survey_id = json.loads(get_survey_response.content)['id']
    else:
        surveys_response.raise_for_status()
        survey_id = json.loads(surveys_response.content)['id']
    print(f'Survey service response: {surveys_response.status_code}, {surveys_response.text}')

    classifier1 = {
        'name': 'COLLECTION_INSTRUMENT',
        'classifierTypes': [
            'COLLECTION_EXERCISE'
        ]
    }
    classifier2 = {
        'name': 'COMMUNICATION_TEMPLATE',
        'classifierTypes': [
            'COLLECTION_EXERCISE'
        ]
    }

    classifier1_response = requests.post(
        url=f'{Config.SURVEY_SERVICE_URL}'
            f'/surveys/{survey_id}/classifiers',
        json=classifier1,
        auth=Config.AUTH)

    if classifier1_response.status_code != 409:
        classifier1_response.raise_for_status()

    classifier2_response = requests.post(
        url=f'{Config.SURVEY_SERVICE_URL}'
            f'/surveys/{survey_id}/classifiers',
        json=classifier2,
        auth=Config.AUTH)

    if classifier2_response.status_code != 409:
        classifier2_response.raise_for_status()

    print(f'Classifier 1 response: {classifier1_response.status_code}, {classifier1_response.text}')
    print(f'Classifier 2 response: {classifier2_response.status_code}, {classifier2_response.text}')
    print(f'SURVEY_ID={survey_id}')

    return survey_id


if __name__ == '__main__':
    create_survey()
