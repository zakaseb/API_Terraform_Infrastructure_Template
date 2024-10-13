module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.13.0"

  name               = "callsign"
  cidr               = var.config["vpc"]["cidr"]
  azs                = var.config["vpc"]["azs"]
  private_subnets    = var.config["vpc"]["private_subnets_cidr"]
  public_subnets     = var.config["vpc"]["public_subnets_cidr"]
  enable_nat_gateway = true
  single_nat_gateway = true
}
