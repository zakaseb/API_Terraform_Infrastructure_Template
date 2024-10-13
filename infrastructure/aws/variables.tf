variable "region" {
  description = "AWS region"
  default     = "us-west-2"
}

variable "config" {
  default = {
    vpc = {
      azs                  = ["us-west-2a", "us-west-2b", "us-west-2c"]
      cidr                 = "10.0.0.0/16"
      private_subnets_cidr = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
      public_subnets_cidr  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
    }
  }
}

variable "app_version" {
  default = "1.0.3"
}

variable "app_port" {
  default = 8887
}
