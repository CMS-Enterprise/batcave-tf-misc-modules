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

variable "NameSpace" {
  description = "Optional for when the GroupName doesn't match the namespace"
  type        = string
  default     = var.GroupName
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

variable "tags" {
  description = "A mapping of tags to assign to all resources"
  type        = map(string)
  default     = {}
}