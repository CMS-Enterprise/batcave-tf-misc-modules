import json
import copy
from datetime import datetime
import boto3
import os

def add_new_entry(data):
    # Gets the last row
    recent_entry = data["entries"][-1]

    # Makes and returns a deep copy of the last row
    duplicated_entry = copy.deepcopy(recent_entry)
    return duplicated_entry

def increment_date(entry):
    # Split up the url and get the date range
    url_parts = entry["url"].split("/")
    date_range = url_parts[-2]

    # Extract the two dates from the date range
    start_date_str, end_date_str = date_range.split("-")
    start_date = datetime.strptime(start_date_str, "%Y%m%d")
    end_date = datetime.strptime(end_date_str, "%Y%m%d")

    # Increment the months accounting for changes in year
    if start_date.month == 12:
        start_date = start_date.replace(year=start_date.year + 1, month=1)
        end_date = end_date.replace(month=end_date.month + 1)
    elif end_date.month == 12:
        start_date = start_date.replace(month=start_date.month + 1)
        end_date = end_date.replace(year=end_date.year + 1, month=1)
    else:
        start_date = start_date.replace(month=start_date.month + 1)
        end_date = end_date.replace(month=end_date.month + 1)

    # Revert Format back to YYMMDD
    start_date = start_date.strftime("%Y%m%d")
    end_date = end_date.strftime("%Y%m%d")

    # Reconstruct Date Range
    new_date_range = f"{start_date}-{end_date}"
    reconstructed_url = entry["url"].replace(date_range, new_date_range)

    return reconstructed_url

def lambda_handler(event, context):
    
    BUCKET_NAME = os.environ['BUCKET_NAME']
    OBJECT_KEY = os.environ['OBJECT_KEY']

    # Initialize the S3 client
    s3 = boto3.client('s3')

    # Download the JSON file from the S3 bucket
    s3.download_file(BUCKET_NAME, OBJECT_KEY, '/tmp/' + OBJECT_KEY)

    # Loads in the new data file
    with open('/tmp/' + OBJECT_KEY, 'r') as json_file:
        data = json.load(json_file)

    # Creates and updates the new entry
    new_entry = add_new_entry(data)
    new_url = increment_date(new_entry)

    # Append new entry
    new_entry["url"] = new_url
    data["entries"].append(new_entry)

    # Rewrite new json file
    with open('/tmp/' + OBJECT_KEY, 'w') as json_file:
        json.dump(data, json_file, indent=2)

    # Upload the JSON file to the S3 bucket
    s3.upload_file('/tmp/' + OBJECT_KEY, BUCKET_NAME, OBJECT_KEY)
    
    return {
        'statusCode': 200
    }

