variable "amis" {
  type = "map"

  default = {
      "us-east-1" = "ami-026c8acd92718196b"
      "us-east-2" = "ami-0dacb0c129b49f529"
  }
}
