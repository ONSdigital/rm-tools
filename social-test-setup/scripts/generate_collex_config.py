import json
import os

from config.setup_config import Config


def generate_config_file():
    collex_config = {
        'inputFiles': ['data/OHS-collection-exercises.csv'],
        'dryRun': False,
        'api': {
            'post-url': f'{Config.COLLECTION_EXERCISE_SERVICE_URL}/collectionexercises',
            'user': Config.USERNAME,
            'password': Config.PASSWORD
        },
        'columnMappings': {
            'Survey_Id': 'surveyRef',
            'Survey_Name': 'name',
            'Collection_Number': 'exerciseRef',
            'Collection_Description': 'userDescription'
        }
    }

    with open(f'./config/collection_exercise_config.json', 'w', encoding='utf-8') as fp:
        json.dump(collex_config, fp, indent=2)
    print('Generated collection exercise loader config')


if __name__ == '__main__':
    generate_config_file()
