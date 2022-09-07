# Copyright (C) 2022 Panther Labs Inc
#
# Panther Enterprise is licensed under the terms of a commercial license available from
# Panther Labs Inc ("Panther Commercial License") by contacting contact@runpanther.com.
# All use, distribution, and/or modification of this software, whether commercial or non-commercial,
# falls under the Panther Commercial License to the extent it is permitted.

output "role_arn" {
  value       = aws_iam_role.log_processing_role.arn
  description = "The ARN of the log processing role that Panther will use to read S3 objects."
}
