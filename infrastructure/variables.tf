variable "config" {
  default = {
    aws = {
      region   = "eu-west"
      vpc_cidr = "10.0.0.0/16"
      vpc_azs  = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

    }

    gcp = {

    }

    azure = {

    }
  }
}
