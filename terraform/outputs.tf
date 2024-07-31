output "frontend_url" {
  value = module.front.frontend_url
}

output "backend_ip" {
  value = module.webserver.backend_url
}

output "bucket_url" {
  value = module.front.bucket_url
}

output "rds_address" {
  value = module.webserver.rds_endpoint
}
