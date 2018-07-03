survey:
	pipenv run python create_survey.py --url http://localhost:8080/surveys --survey ~/projects/rm/rm-tools/social-test-setup/data/OHS_survey_details.json --user admin --password secret

collection-exercise:
	pipenv run python ././../collex-loader/load.py ./config/collection_exercise_config.json

collection-events:
	pipenv run python ././../collex-loader/load_events.py ./config/events_config.json

load-sample:
	pipenv run python load_social_sample.py  # Needs config

link-sample:
	pipenv run python link_sample_to_collex.py  # Needs config

upload-ci:
	pipenv run python upload_collection_instrument.py  # Needs config

link-ci:
	pipenv run python link_ci.py  # Needs config

action-rules:
	pipenv run python create_action_rule.py  # Needs config

execute-collection-exercise:
	pipenv run python execute_collection_exercise.py  # Needs config