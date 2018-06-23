output "target_group_http" {
  description = "ARN of a target group of workers for HTTP traffic"
  value       = "${aws_lb_target_group.workers-http.arn}"
}

output "target_group_https" {
  description = "ARN of a target group of workers for HTTPS traffic"
  value       = "${aws_lb_target_group.workers-https.arn}"
}
