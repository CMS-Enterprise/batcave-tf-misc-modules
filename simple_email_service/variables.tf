variable email {
  type = string
  default = "email@example.com"
}

variable create_email_identity {
  type = bool
  default = true
}

variable domain {
  type = string
  default = "example.com"
}

variable create_domain_identity {
  type = bool
  default = false
}