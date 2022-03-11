
# ENDPOINT
resource "aws_vpc_endpoint" "main-vpc-endpoint" {
  vpc_id       = aws_vpc.main-vpc.id
  service_name = "com.amazonaws.us-east-1.s3"
}
# associate route table with VPC endpoint
resource "aws_vpc_endpoint_route_table_association" "main-private-route-table-association" {
  route_table_id  = aws_route_table.private-route-table.id
  vpc_endpoint_id = aws_vpc_endpoint.main-vpc-endpoint.id
}
