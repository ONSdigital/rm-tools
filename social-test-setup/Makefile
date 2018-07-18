create-survey:
	pipenv run python -m scripts.create_survey

create-collection-exercise:
	pipenv run python -m scripts.generate_collex_config
	pipenv run python ././../collex-loader/load.py ./config/collection_exercise_config.json
	pipenv run python -m scripts.get_collection_exercise_id
	pipenv run python -m scripts.get_action_plan_id

create-collection-events:
	pipenv run python -m scripts.generate_events_config
	pipenv run python ././../collex-loader/load_events.py ./config/events_config.json

load-sample:
	pipenv run python -m scripts.load_social_sample

link-sample:
	pipenv run python -m scripts.link_sample_to_collex

load-ci:
	pipenv run python -m scripts.upload_collection_instrument
	pipenv run python -m scripts.get_collection_instrument_id

link-ci:
	pipenv run python -m scripts.link_ci

create-action-rules:
	pipenv run python -m  scripts.create_action_rules

execute-collection-exercise:
	pipenv run python -m scripts.execute_collection_exercise

setup-and-execute:
	pipenv run invoke setup-and-execute