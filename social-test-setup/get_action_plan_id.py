import os

import requests

from config import Config

ACTION_SERVICE_URL = os.getenv('ACTION_SERVICE_URL')

if __name__ == '__main__':
    response = requests.get(f'{ACTION_SERVICE_URL}/actionplans',
                            auth=Config.AUTH)
    response.raise_for_status()
    actionplans = response.json()
    ohs_actionplan = [actionplan for actionplan in actionplans if actionplan.get('name') == 'OHS H 1']
    ohs_actionplan = ohs_actionplan[0]
    print(f'ACTION_PLAN_ID={ohs_actionplan["id"]}')
