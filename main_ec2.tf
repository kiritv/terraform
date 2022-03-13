# EC2 instance in public subnet
resource "aws_instance" "main-public-instance" {
  count                  = var.install-in-number-of-availability-zone
  ami                    = data.aws_ami.main-ami.id
  instance_type          = "t2.micro"
  availability_zone      = data.aws_availability_zones.main-azs.names[count.index]
  subnet_id              = aws_subnet.public-subnet.*.id[count.index]
  vpc_security_group_ids = [aws_security_group.public-security-group.id]
  key_name               = "main-key"
  user_data              = filebase64("${path.module}/user-data.sh")

  tags = {
    Name = "${local.environment-name}-public-server-${count.index + 1}"
  }
}
# EC2 instance in private subnet
resource "aws_instance" "main-private-instance" {
  count                  = var.install-in-number-of-availability-zone
  ami                    = data.aws_ami.main-ami.id
  instance_type          = "t2.micro"
  availability_zone      = data.aws_availability_zones.main-azs.names[count.index]
  subnet_id              = aws_subnet.private-subnet.*.id[count.index]
  vpc_security_group_ids = [aws_security_group.private-security-group.id]
  key_name               = "main-key"
  iam_instance_profile   = aws_iam_instance_profile.ec2-s3-profile.name
  #user_data              = filebase64("${path.module}/user-data.sh")

  tags = {
    Name = "${local.environment-name}-private-server-${count.index + 1}"
  }
}
