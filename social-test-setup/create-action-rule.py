import json
from pprint import pprint

import requests
from requests.auth import HTTPBasicAuth

action_url = 'http://localhost:8151/'
user = 'admin'
password = 'secret'

action_rule_pre_not = {
    'actionPlanId': 'e30f8411-bb2b-4b86-a936-bd68111a07d0',  # Changes every run
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
    pre_not_response = requests.post(url=f'{action_url}actionrules)',
                                     json=action_rule_pre_not,
                                     auth=HTTPBasicAuth(username=user, password=password))

    pprint(json.loads(pre_not_response.content))

    not_response = requests.post(url=f'{action_url}actionrules)',
                                 json=action_rule_not,
                                 auth=HTTPBasicAuth(username=user, password=password))

    pprint(json.loads(pre_not_response.content))
