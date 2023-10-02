import logging
import os

from ebs_volume_tasks import cleanup

logging.getLogger().setLevel(os.environ["LOG_LEVEL"] if "LOG_LEVEL" in os.environ else logging.WARN)


def lambda_handler(event, context):
    cleanup()
