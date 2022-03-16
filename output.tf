output "main-availability-zones" {
  description = "List of all availability zones"
  value       = data.aws_availability_zones.main-azs.names
}

# output "main-vpc-id" {
#   description = "VPC"
#   value       = aws_vpc.main-vpc.*.id[0]
# }

# output "main-aws-internet-gatewat" {
#   description = "IGW"
#   value       = aws_internet_gateway.main-internet-gateway.*.id[0]
# }
