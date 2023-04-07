import os

def handler(event, context):
    
    account_name = os.environ.get("ACCOUNT_NAME")
    try:
        event['detail']['findings']['AwsAccountId'] = account_name
    except Exception as e:
        print('Error encountered during parsing of event for AwsAccountId: ' + e)
        return event
    return event