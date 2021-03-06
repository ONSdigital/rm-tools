import os

from requests.auth import HTTPBasicAuth


class Config:
    USERNAME = os.getenv('AUTH_USERNAME')
    PASSWORD = os.getenv('AUTH_PASSWORD')
    AUTH = HTTPBasicAuth(USERNAME, PASSWORD)

    SURVEY_SERVICE_URL = os.getenv('SURVEY_SERVICE_URL')
    COLLECTION_EXERCISE_SERVICE_URL = os.getenv('COLLECTION_EXERCISE_SERVICE_URL')
    SAMPLE_SERVICE_URL = os.getenv('SAMPLE_SERVICE_URL')
    COLLECTION_INSTRUMENT_SERVICE_URL = os.getenv('COLLECTION_INSTRUMENT_SERVICE_URL')
    ACTION_SERVICE_URL = os.getenv('ACTION_SERVICE_URL')
