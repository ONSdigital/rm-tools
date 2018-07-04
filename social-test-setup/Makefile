create-survey:
	pipenv run python create_survey.py

create-collection-exercise:
	pipenv run python ././../collex-loader/load.py ./config/collection_exercise_config.json
	pipenv run python get_collection_exercise_id.py
	pipenv run python get_action_plan_id.py

create-collection-events:
	pipenv run python ././../collex-loader/load_events.py ./config/events_config.json

load-sample:
	pipenv run python load_social_sample.py

link-sample:
	pipenv run python link_sample_to_collex.py

load-ci:
	pipenv run python upload_collection_instrument.py

link-ci:
	pipenv run python link_ci.py

create-action-rules:
	pipenv run python create_action_rules.py

execute-collection-exercise:
	pipenv run python execute_collection_exercise.py