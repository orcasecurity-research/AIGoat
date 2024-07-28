output "frontend_url" {
  value = module.front.frontend_url
}

output "backend_url" {
  value = module.webserver.backend_url
}

output "rds_endpoint" {
  value = module.webserver.rds_endpoint
}

output "bucket_url" {
  value = module.front.bucket_url
}

output "rds_address" {
  value = module.webserver.rds_endpoint
}

output "output_integrity_api_gateway_url" {
  value = module.output_integrity.api_invoke_url
}