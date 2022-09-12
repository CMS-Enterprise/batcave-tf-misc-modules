from ebs_volume_tasks import cleanup


def lambda_handler(event, context):
    cleanup()
