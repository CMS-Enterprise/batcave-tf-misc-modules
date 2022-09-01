# Copyright (C) 2022 Panther Labs Inc
#
# Panther Enterprise is licensed under the terms of a commercial license available from
# Panther Labs Inc ("Panther Commercial License") by contacting contact@runpanther.com.
# All use, distribution, and/or modification of this software, whether commercial or non-commercial,
# falls under the Panther Commercial License to the extent it is permitted.



variable "aws_partition" {
  type        = string
  default     = "aws"
  description = "AWS partition of the account running the Panther backend e.g aws, aws-cn, or aws-us-gov"
}

variable "panther_aws_account_id" {
  type        = string
  description = "The AWS account ID of your Panther instance"
}

variable "role_suffix" {
  type        = string
  description = "A unique identifier that will be used as the IAM role suffix"
}

variable "role_path" {
  type        = string
  description = "Path for IAM Roles and managed policies required."
  default     = "/delegatedadmin/developer/"
}
