output "vpc_id" {
  description = "vpc id"
  value       = aws_vpc.vpc.id
}

output "subnet_group_id" {
  description = "vpc subnet group"
  value       = aws_db_subnet_group.dbsubnet.id
}

output "subnet1" {
  description = "subnet1"
  value       = aws_subnet.sub1.id
}

output "subnet2" {
  description = "subnet2"
  value       = aws_subnet.sub2.id
}
#
# output "subnet3" {
#   description = "subnet3"
#   value       = aws_subnet.sub3.id
# }

output "subd_public" {
  description = "subd-public"
  value       = aws_subnet.subnet-public.id
}