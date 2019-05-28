# Outputs for global load balancing

output "instance_group" {
  description = "Worker managed instance group full URL"
  value       = google_compute_region_instance_group_manager.workers.instance_group
}

# Outputs for regional load balancing

output "target_pool" {
  description = "Worker target pool self link"
  value       = google_compute_target_pool.workers.self_link
}

