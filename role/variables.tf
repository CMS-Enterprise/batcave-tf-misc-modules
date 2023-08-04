variable "OIDCProviderID" {
  description = "The OIDC Provider ID"
  type        = string
  default     = null
}

variable "SDLUserArn" {
  description = "The SDL User Arn"
  type        = string
  default     = null
}

variable "SDLExternalId" {
  description = "The SDL External ID"
  type        = string
  default     = "0000"
}

variable "ApiResources" {
  description = "The list of API Resources"
  type        = list(string)
  default     = null
}

variable "SQSStackName" {
  description = "The SQS Stack Name"
  type        = string
  default     = null
}

variable "S3StackName" {
  description = "The S3 Stack Name"
  type        = string
  default     = null
}

variable "GroupName" {
  description = "The Group Name"
  type        = string
  default     = null
}

variable "iam_role_path" {
  type    = string
  default = "/delegatedadmin/developer/"
}

variable "permissions_boundary" {
  type        = string
  default     = null
  description = "IAM Role Permissions Boundary, if required."
}

variable "make_job_scheduler_policy_and_role" {
  type        = bool
  default     = true
  description = "Create job scheduler policy, attachment, and role, if required"
}
