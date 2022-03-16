
# ENDPOINT
resource "aws_vpc_endpoint" "main-vpc-endpoint" {
  count        = var.install-s3 ? 1 : 0
  vpc_id       = aws_vpc.main-vpc.*.id[0]
  service_name = "com.amazonaws.us-east-1.s3"
}
# associate route table with VPC endpoint
resource "aws_vpc_endpoint_route_table_association" "main-private-route-table-association" {
  count           = var.install-s3 ? 1 : 0
  route_table_id  = aws_route_table.private-route-table.*.id[count.index]
  vpc_endpoint_id = aws_vpc_endpoint.main-vpc-endpoint.*.id[count.index]
}
