variable "amis" {
  type = "map"

  default = {
      "us-east-1" = "ami-026c8acd92718196b"
      "us-east-2" = "ami-0dacb0c129b49f529"
  }
}


variable "cdirs_acesso_remote" {
  type = "list"
  default = ["179.162.54.183/32", "193.37.252.61/32"]
}

variable "key_name" {
  default = "terraform-laptop"
}
