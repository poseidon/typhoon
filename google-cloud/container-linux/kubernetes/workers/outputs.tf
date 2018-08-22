output "instance_group" {
  description = "Full URL of the worker managed instance group"
  value       = "${google_compute_region_instance_group_manager.workers.instance_group}"
}
