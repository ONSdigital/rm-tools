from invoke import task

from scripts.create_action_rules import create_action_rules
from scripts.create_survey import create_survey
from scripts.execute_collection_exercise import execute_collection_exercise
from scripts.generate_collex_config import generate_collex_config_file
from scripts.generate_events_config import generate_events_config_file
from scripts.get_action_plan_id import get_action_plan_id
from scripts.get_collection_exercise_id import get_collex_id
from scripts.get_collection_instrument_id import get_collection_instrument_id
from scripts.link_ci import link_ci
from scripts.link_sample_to_collex import link_sample
from scripts.load_social_sample import load_sample
from scripts.upload_collection_instrument import upload_ci


@task
def setup_and_execute(ctx):

    # Create survey
    survey_id = create_survey()

    # Create collection exercise
    generate_collex_config_file()
    ctx.run('pipenv run python ././../collex-loader/load.py ./config/collection_exercise_config.json')
    collection_exercise_id = get_collex_id()
    action_plan_id = get_action_plan_id()

    # Load events
    generate_events_config_file(collection_exercise_id)
    ctx.run('pipenv run python ././../collex-loader/load_events.py ./config/events_config.json')

    # Load and link sample
    sample_summary_id = load_sample()
    link_sample(collection_exercise_id, sample_summary_id)

    # Load and link CI
    upload_ci(survey_id, collection_exercise_id)
    collection_instrument_id = get_collection_instrument_id(collection_exercise_id)
    link_ci(collection_exercise_id, collection_instrument_id)

    # Create action plans
    create_action_rules(action_plan_id)

    # Execute collection exercise
    execute_collection_exercise(collection_exercise_id)
