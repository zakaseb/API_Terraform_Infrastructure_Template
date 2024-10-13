terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "Callsign"

    workspaces {
      name = "infrastructure-azure"
    }
  }
}
