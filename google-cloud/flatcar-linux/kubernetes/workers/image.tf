# Flatcar Linux most recent image from channel
data "google_compute_image" "flatcar-linux" {
  project = "kinvolk-public"
  family  = var.os_image
}
