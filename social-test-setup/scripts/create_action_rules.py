import json
import os
from pprint import pprint

import requests

from config.setup_config import Config


def create_action_rules(action_plan_id: str):
    action_rule_pre_not = {
        'actionPlanId': action_plan_id,
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

    pre_not_response = requests.post(url=f'{Config.ACTION_SERVICE_URL}/actionrules',
                                     json=action_rule_pre_not,
                                     auth=Config.AUTH)
    pre_not_response.raise_for_status()
    not_response = requests.post(url=f'{Config.ACTION_SERVICE_URL}/actionrules',
                                 json=action_rule_not,
                                 auth=Config.AUTH)
    not_response.raise_for_status()
    pprint(json.loads(pre_not_response.content))
    pprint(json.loads(not_response.content))


if __name__ == '__main__':
    create_action_rules(os.getenv('ACTION_PLAN_ID'))
