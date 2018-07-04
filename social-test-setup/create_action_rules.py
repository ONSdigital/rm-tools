import json
import os
from pprint import pprint

import requests

from config import Config

ACTION_SERVICE_URL = os.getenv('ACTION_SERVICE_URL')
ACTION_PLAN_ID = os.getenv('ACTION_PLAN_ID')

action_rule_pre_not = {
    'actionPlanId': ACTION_PLAN_ID,
    'actionTypeName': 'SOCIALPRENOT',
    'name': 'OHSSOCIALPRENOT+0',
    'description': 'OHS Social Pre-notification (+0 days)',
    'daysOffset': 0,
    'priority': 3
}

action_rule_not = action_rule_pre_not
action_rule_not['actionTypeName'] = 'SOCIALNOT'
action_rule_not['name'] = 'OHSSOCIALNOT +0'
action_rule_not['description'] = 'OHS Social Notification (+0 days)'

if __name__ == '__main__':
    pre_not_response = requests.post(url=f'{ACTION_SERVICE_URL}/actionrules',
                                     json=action_rule_pre_not,
                                     auth=Config.AUTH)

    pre_not_response.raise_for_status()

    not_response = requests.post(url=f'{ACTION_SERVICE_URL}/actionrules',
                                 json=action_rule_not,
                                 auth=Config.AUTH)

    not_response.raise_for_status()

    pprint(json.loads(pre_not_response.content))
    pprint(json.loads(not_response.content))
