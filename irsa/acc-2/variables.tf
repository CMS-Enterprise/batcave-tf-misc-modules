variable "oidc_url"{
  default = "https://oidc.eks.us-east-1.amazonaws.com/id/A55CFAFFD4C0C1A7F247E0EFA8D3953D"
}

variable "thumbprint" {
  default = "9e99a48a9960b14926bb7f3b02e22da2b0ab7280"
}

variable "permissions_boundary" {
  default = "arn:aws:iam::831579051573:policy/cms-cloud-admin/developer-boundary-policy"
}

variable "role_path" {
  default = "/delegatedadmin/developer/"
}