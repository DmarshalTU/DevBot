# Creste alb
resource "aws_alb" "alb" {
  name            = "alb"
  load_balancer_type = "application"
  internal           = false
  security_groups = [aws_security_group.alb-SG.id]
  subnets         = [aws_subnet.sub-public-1a.id, aws_subnet.sub-public-1b.id]
  tags = {
    Name = "alb"
  }
}

# Create listener
resource "aws_alb_listener" "listener_http" {
  load_balancer_arn = "${aws_alb.alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.alb-target-group.arn}"
    type             = "forward"
  }
}



# Create target group
resource "aws_alb_target_group" "alb-target-group" {
  name     = "alb-target-group"
  vpc_id   = aws_vpc.main.id
  target_type = "instance"
  port     = 80
  protocol = "HTTP"
  health_check {
    enabled = true
    healthy_threshold = 3
    unhealthy_threshold = 10
    timeout = 5
    interval = 10
    path = "/"
    port = 80
  }
  tags = {
    Name = "alb-target-group"
  }
}

# Create target group attachment
resource "aws_alb_target_group_attachment" "instances-attachment-01" {
  target_group_arn = aws_alb_target_group.alb-target-group.arn
  target_id        = "${aws_instance.private-01.id}"
  port             = 80
}

resource "aws_alb_target_group_attachment" "instances-attachment-02" {
  target_group_arn = aws_alb_target_group.alb-target-group.arn
  target_id        = "${aws_instance.private-02.id}"
  port             = 80
}