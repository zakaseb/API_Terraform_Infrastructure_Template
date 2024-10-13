resource "google_storage_bucket" "callsign" {
  name          = "callsigndata"
  location      = var.GOOGLE_REGION
  force_destroy = true
}
