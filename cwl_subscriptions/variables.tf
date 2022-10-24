
variable "cluster_name" {
  type        = string
  description = "Cluster Name."
}

variable "buffer_size" {
  type        = number
  default     = 128 # Maximum
  description = " Buffer incoming data to the specified size, in MBs, before delivering it to the destination"
}

variable "buffer_interval_in_seconds" {
  type        = number
  default     = 300 # 5min
  description = "Buffer incoming data for the specified period of time, in seconds, before delivering it to the destination. The default value is 300"
}

variable "iam_role_path" {
  default = "/delegatedadmin/developer/"
}

variable "permissions_boundary" {
  type = string
  default = ""
  description = "IAM Role Permissions Boundary, if required."
}