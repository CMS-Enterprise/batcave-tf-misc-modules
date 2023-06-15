variable "bucket_name" {
  description = "The name of the bucket that the runner requires access to"
  type        = string
  default     = null
}

variable "iam_path" {
  description = "The IAM path to use for the policy"
  type        = string
  default     = null
}

variable "external_account_id" {
  description = "Account id that is being granted access to the bucket"
  type        = string
  default     = null
}

variable "external_user_name" {
  description = "User's name that is being granted access to the bucket"
  type        = string
  default     = null
}
