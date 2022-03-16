resource "aws_launch_template" "main-launch-template" {
  count                  = var.install-asg-alb ? 1 : 0
  name                   = "${local.environment-name}-launch-template"
  image_id               = data.aws_ami.main-ami.id
  instance_type          = "t2.micro"
  key_name               = "main-key"
  vpc_security_group_ids = [aws_security_group.public-security-group.*.id[0]]
  user_data              = filebase64("${path.module}/user-data.sh")
}

resource "aws_alb" "main-application-load-balancer" {
  count              = var.install-asg-alb ? 1 : 0
  name               = "${local.environment-name}-application-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public-security-group.*.id[0]]
  subnets            = aws_subnet.public-subnet.*.id

  tags = {
    Name        = "${local.environment-name}-application-load-balancer"
    Environment = "${local.environment-name}"
  }
}

resource "aws_alb_listener" "main-listener-http" {
  count             = var.install-asg-alb ? 1 : 0
  load_balancer_arn = aws_alb.main-application-load-balancer.*.arn[count.index]
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.main-target-group.*.arn[count.index]
    type             = "forward"
  }
}

resource "aws_autoscaling_group" "main-auto-scaling-group" {
  count                     = var.install-asg-alb ? 1 : 0
  name                      = "${local.environment-name}-auto-scaling-group"
  vpc_zone_identifier       = aws_subnet.public-subnet.*.id
  desired_capacity          = 1
  max_size                  = 1
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true

  launch_template {
    id      = aws_launch_template.main-launch-template.*.id[count.index]
    version = aws_launch_template.main-launch-template.*.latest_version[count.index]
  }

  depends_on = [
    aws_alb.main-application-load-balancer
  ]
}

resource "aws_alb_target_group" "main-target-group" {
  count    = var.install-asg-alb ? 1 : 0
  name     = "${local.environment-name}-instance-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main-vpc.*.id[0]
  stickiness {
    type = "lb_cookie"
  }
}
resource "aws_alb_target_group_attachment" "main-ec2-alw-tg-attachment" {
  count            = var.install-asg-alb ? var.install-in-number-of-availability-zone : 0
  target_group_arn = aws_alb_target_group.main-target-group.*.arn[count.index]
  target_id        = aws_instance.main-public-instance.*.id[count.index]
  port             = 80
}
