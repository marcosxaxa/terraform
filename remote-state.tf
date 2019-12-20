terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "marcosxaxa"

    workspaces {
      name = "aws-marcosxaxa"
    }
  }
}