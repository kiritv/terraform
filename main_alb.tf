resource "aws_launch_template" "main-launch-template" {
  name                   = "${local.environment-name}-launch-template"
  image_id               = data.aws_ami.main-ami.id
  instance_type          = "t2.micro"
  key_name               = "main-key"
  vpc_security_group_ids = [aws_security_group.public-security-group.id]
  user_data              = filebase64("${path.module}/user-data.sh")
}

# resource "aws_placement_group" "main-placement-group" {
#   name     = "${local.environment-name}-placement-group"
#   strategy = "cluster"
# }

resource "aws_autoscaling_group" "main-auto-scaling-group" {
  name                = "${local.environment-name}-auto-scaling-group"
  vpc_zone_identifier = aws_subnet.public-subnet.*.id
  #availability_zones        = data.aws_availability_zones.main-azs.names
  desired_capacity          = 1
  max_size                  = 1
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  #placement_group           = aws_placement_group.main-placement-group.id

  launch_template {
    id      = aws_launch_template.main-launch-template.id
    version = aws_launch_template.main-launch-template.latest_version
  }

  load_balancers = [aws_alb.main-application-load-balancer.id]
}

# lb = ALB
resource "aws_alb_target_group" "main-target-group" {
  name     = "${local.environment-name}-instance-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main-vpc.id
  stickiness {
    type = "lb_cookie"
  }
}

resource "aws_alb" "main-application-load-balancer" {
  name               = "${local.environment-name}-application-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public-security-group.id]
  subnets            = aws_subnet.public-subnet.*.id

  tags = {
    Name        = "${local.environment-name}-application-load-balancer"
    Environment = "${local.environment-name}"
  }
}

resource "aws_alb_listener" "main-listener-http" {
  load_balancer_arn = aws_alb.main-application-load-balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.main-target-group.arn
    type             = "forward"
  }
}
