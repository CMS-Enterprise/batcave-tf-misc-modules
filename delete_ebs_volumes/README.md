# Lambda function to delete Available EBS Volumes

This lambda function will delete EBS volumes whose status is "Available".
This function will run everyday at 11 PM Hawaii time (5 AM EST).

### Avoid Deleteion of EBS Volumes

To avoid deletion of an EBS Volume, please create the following Tag.

Key : DELETE
Value : NO

Note - "DELETE" is case-sensetive.
