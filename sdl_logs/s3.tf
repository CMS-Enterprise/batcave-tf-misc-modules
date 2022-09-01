data "aws_s3_bucket" "cms_logging_bucket" {
  bucket = "cms-cloud-${data.aws_caller_identity.current.account_id}-us-east-1"
}

# resource "aws_s3_bucket_notification" "bucket_notification" {
#   bucket      = data.aws_s3_bucket.cms_logging_bucket.id
#   eventbridge = true
# }

# Bucket notifications are managed as a single resource by AWS. 
# If an organizational change is made from cms cloud, our notifications will be overwritten, and if we
# make a change, we overwrite their settings, so this became a last resort
# This local-exec requires aws cli on the local machine
# Grabs the current bucket notification configuration and ensures
# .EventBridgeConfiguration = {} is present. An empty JSON object means this setting is enabled.
resource "null_resource" "bucket_notification" {
  triggers = {
    notification_configuration = data.external.bucket_notification.result["eventbridge"]
  }
  provisioner "local-exec" {
    command = tobool(data.external.bucket_notification.result["eventbridge"]) ? "echo blank" :"aws s3api put-bucket-notification-configuration --bucket ${data.aws_s3_bucket.cms_logging_bucket.id} --notification-configuration \"$(aws s3api get-bucket-notification-configuration --bucket ${data.aws_s3_bucket.cms_logging_bucket.id} --output json | jq '.EventBridgeConfiguration = {}')\""
  }
}

# this has some custom jq because the external provider cant deal with arrays in json objects and lambdaconfig is an array
# it is the trigger for the bucket notification code above to check if it needs to overwrite
data "external" "bucket_notification" {
program = ["sh", "-c", "aws s3api get-bucket-notification-configuration --bucket ${data.aws_s3_bucket.cms_logging_bucket.id} --output json | jq -r '.EventBridgeConfiguration |if .==null then {\"eventbridge\":\"false\"} else {\"eventbridge\":\"true\"} end'"]
}
