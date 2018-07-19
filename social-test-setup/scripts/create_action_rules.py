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

    action_rule_not = {
        'actionPlanId': action_plan_id,
        'actionTypeName': 'SOCIALNOT',
        'name': 'OHSSOCIALNOT +0',
        'description': 'OHS Social Notification (+0 days)',
        'daysOffset': 0,
        'priority': 3
    }

    pre_not_response = requests.post(url=f'{Config.ACTION_SERVICE_URL}/actionrules',
                                     json=action_rule_pre_not,
                                     auth=Config.AUTH)
    pprint(json.loads(pre_not_response.content))
    pre_not_response.raise_for_status()
    not_response = requests.post(url=f'{Config.ACTION_SERVICE_URL}/actionrules',
                                 json=action_rule_not,
                                 auth=Config.AUTH)
    pprint(json.loads(not_response.content))
    not_response.raise_for_status()


if __name__ == '__main__':
    create_action_rules(os.getenv('ACTION_PLAN_ID'))
