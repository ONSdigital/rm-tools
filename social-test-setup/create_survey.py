import argparse
import json

import requests
from requests.auth import HTTPBasicAuth


def parse_args():
    parser = argparse.ArgumentParser(description='Create survey in survey service')
    parser.add_argument("--survey", help="Path to survey details JSON")
    parser.add_argument("--url", help="URL to post survey", nargs='?')
    parser.add_argument("--user", help="User to post survey", nargs='?')
    parser.add_argument("--password", help="Password to post survey", nargs='?')
    return parser.parse_args()


def post_survey(survey, url, user, password):
    return requests.post(url=url,
                         json=survey,
                         auth=HTTPBasicAuth(username=user, password=password))


if __name__ == "__main__":

    args = parse_args()

    with open(args.survey) as fp:
        survey = json.load(fp)

    surveys_response = post_survey(survey=survey,
                                   url=str(args.url),
                                   user=str(args.user),
                                   password=str(args.password))

    print(f'Survey service response: {surveys_response.status_code}, {surveys_response.content.decode()}')
