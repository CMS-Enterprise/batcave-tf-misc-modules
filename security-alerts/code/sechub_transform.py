import os

def handler(event, context):
    
    account_name = os.environ.get("ACCOUNT_NAME")
    event['account'] = account_name

    return event