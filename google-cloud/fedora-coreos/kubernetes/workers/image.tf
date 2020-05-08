
# Fedora CoreOS most recent image from stream
data "google_compute_image" "fedora-coreos" {
  project = "fedora-coreos-cloud"
  family  = "fedora-coreos-${var.os_stream}"
}
