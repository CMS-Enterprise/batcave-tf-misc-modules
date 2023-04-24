variable "create_role" {
  description = "Whether to create a role"
  type        = bool
  default     = true
}

variable "role_name" {
  description = "Name of IAM role"
  type        = string
  default     = "vpc-cni"
}

variable "role_path" {
  description = "Path of IAM role"
  type        = string
  default     = "/delegatedadmin/developer/"
}

variable "role_permissions_boundary_arn" {
  description = "Permissions boundary ARN to use for IAM role"
  type        = string
  default     = "arn:aws:iam::373346310182:policy/cms-cloud-admin/developer-boundary-policy"
}

variable "role_description" {
  description = "IAM Role description"
  type        = string
  default     = null
}

variable "role_name_prefix" {
  description = "IAM role name prefix"
  type        = string
  default     = null
}

variable "policy_name_prefix" {
  description = "IAM policy name prefix"
  type        = string
  default     = "AmazonEKS_"
}

variable "role_policy_arns" {
  description = "ARNs of any policies to attach to the IAM role"
  type        = map(string)
  default     = {}
}

variable "oidc_providers" {
  description = "Map of OIDC providers where each provider map should contain the `provider`, `provider_arn`, and `namespace_service_accounts`"
  type        = any
  default     = {
    one = {
      provider_arn               = ""
      namespace_service_accounts = ["default:default"]
    }
  }
}

variable "tags" {
  description = "A map of tags to add the the IAM role"
  type        = map(any)
  default     = {}
}

variable "force_detach_policies" {
  description = "Whether policies should be detached from this role when destroying"
  type        = bool
  default     = true
}

variable "max_session_duration" {
  description = "Maximum CLI/API session duration in seconds between 3600 and 43200"
  type        = number
  default     = null
}

variable "assume_role_condition_test" {
  description = "Name of the [IAM condition operator](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements_condition_operators.html) to evaluate when assuming the role"
  type        = string
  default     = "StringEquals"
}

################################################################################
# Policies
################################################################################
variable "app_name" {
  description = "App name (ie. Flux, Velero, etc.)"
  type        = string
  default     = ""
}

# Velero
variable "attach_velero_policy" {
  description = "Determines whether to attach the Velero IAM policy to the role"
  type        = bool
  default     = false
}

variable "velero_s3_bucket_arns" {
  description = "List of S3 Bucket ARNs that Velero needs access to in order to backup and restore cluster resources"
  type        = list(string)
  default     = ["*"]
}

# SOPS
variable "attach_sops_policy" {
  description = "Determines whether to attach the SOPS policy to the role"
  type        = bool
  default     = false
}

variable "sops_arn" {
  description = "SOPS ARN to allow access to"
  type        = string
  default     = ""
}

# S3
variable "attach_s3_policy" {
  description = "Determines whether to attach the S3 to the role"
  type        = bool
  default     = false
}

variable "s3_bucket_arns" {
  description = "List of S3 Bucket ARNs to allow access to"
  type        = list(string)
  default     = [""]
}

# DynamoDB
variable "attach_dynamodb_policy" {
  description = "Determines whether to attach the dynamodb policy to the role"
  type        = bool
  default     = false
}

variable "dynamodb_arn" {
  description = "Dynamodb table to allow access to"
  type        = string
  default     = ""
}

# Secrets Manager
variable "attach_secretsmanager_policy" {
  description = "Determines whether to attach the secrets manager permissions to the role"
  type        = bool
  default     = false
}

variable "secret_arns" {
  description = "ARNs of secrets in secrets manager to add to policy"
  type        = list(string)
  default     = []
  validation {
    condition = !anytrue([for arn in var.secret_arns : (length(regexall("\\*|\\?", arn)) == 0 ? false : true)] )
    error_message = "No '*' or '?' allowed in secret_arns variable"
  }
}

# RDS
variable "attach_rds_policy" {
  description = "Determines whether to attach the rds permissions to the role"
  type        = bool
  default     = false
}

variable "rds_arns" {
  description = "ARNs of rds to add to policy"
  type        = list(string)
  default     = []
  validation {
    condition = !anytrue([for arn in var.rds_arns : (length(regexall("\\*|\\?", arn)) == 0 ? false : true)] )
    error_message = "No '*' or '?' allowed in rds_arns variable"
  }
}

# SES
variable "attach_ses_policy" {
  description = "Determines whether to attach the ses permissions to the role"
  type        = bool
  default     = false
}

variable "ses_arns" {
  description = "ARNs of ses to add to policy"
  type        = list(string)
  default     = []
  validation {
    condition = !anytrue([for arn in var.ses_arns : (length(regexall("\\*|\\?", arn)) == 0 ? false : true)] )
    error_message = "No '*' or '?' allowed in ses_arns variable"
  }
}

