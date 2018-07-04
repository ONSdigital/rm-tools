import os

from requests.auth import HTTPBasicAuth


class Config:
    USERNAME = os.getenv('AUTH_USERNAME')
    PASSWORD = os.getenv('AUTH_PASSWORD')
    AUTH = HTTPBasicAuth(USERNAME, PASSWORD)
