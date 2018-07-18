import os

import requests

from config.setup_config import Config


def get_action_plan_id() -> str:
    global ohs_actionplan
    response = requests.get(f'{Config.ACTION_SERVICE_URL}/actionplans',
                            auth=Config.AUTH)
    response.raise_for_status()
    actionplans = response.json()
    ohs_actionplan = [actionplan for actionplan in actionplans if actionplan.get('name') == 'OHS H 1']
    ohs_actionplan = ohs_actionplan[0]
    actionplan_id = ohs_actionplan['id']
    print(f'ACTION_PLAN_ID={actionplan_id}')
    return actionplan_id


if __name__ == '__main__':
    get_action_plan_id()
