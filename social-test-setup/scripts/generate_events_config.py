import json
import os

from config.setup_config import Config


def generate_events_config_file(collection_exercise_id: str):
    events_config = {
        "inputFiles": ["data/test-1-events.csv"],
        "dryRun": False,
        "api": {
            "post-url": f"{Config.COLLECTION_EXERCISE_SERVICE_URL}/collectionexercises/{collection_exercise_id}/events",
            "get-url": f"{Config.COLLECTION_EXERCISE_SERVICE_URL}/collectionexercises/1/survey/999",
            "user": Config.USERNAME,
            "password": Config.PASSWORD
        },
        "columnMappings": {
            "survey_code": "surveyRef",
            "survey_period": "exerciseRef"
        }
    }

    with open('./config/events_config.json', 'w', encoding='utf-8') as fp:
        json.dump(events_config, fp, indent=2)
    print('Generated events loader config')


if __name__ == '__main__':
    generate_events_config_file(os.getenv('COLLECTION_EXERCISE_ID'))
