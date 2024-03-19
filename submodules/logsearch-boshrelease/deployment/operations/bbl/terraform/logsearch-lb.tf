# Load Balancer
resource "aws_lb" "logsearch_lb" {
  name               = "${var.short_env_id}-logsearch-lb"
  load_balancer_type = "network"
  subnets            = ["${aws_subnet.lb_subnets.*.id}"]
  tags = {
    yor_trace = "2e1f16a3-edcc-4caa-ab80-9c9b8870698e"
  }
}

# Listener for Kibana
resource "aws_lb_listener" "logsearch_lb_80" {
  load_balancer_arn = "${aws_lb.logsearch_lb.arn}"
  protocol          = "TCP"
  port              = 80

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.logsearch_lb_80.arn}"
  }
}

resource "aws_lb_target_group" "logsearch_lb_80" {
  name     = "logsearch80"
  port     = 80
  protocol = "TCP"
  vpc_id   = "${local.vpc_id}"

  health_check {
    healthy_threshold   = 10
    unhealthy_threshold = 10
    interval            = 30
    protocol            = "TCP"
  }
  tags = {
    yor_trace = "4656b011-b061-4301-ace2-1e36d7d6e862"
  }
}

# Listener for Cluster Monitor
resource "aws_lb_listener" "logsearch_lb_8080" {
  load_balancer_arn = "${aws_lb.logsearch_lb.arn}"
  protocol          = "TCP"
  port              = 8080

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.logsearch_lb_8080.arn}"
  }
}

resource "aws_lb_target_group" "logsearch_lb_8080" {
  name     = "logsearch8080"
  port     = 8080
  protocol = "TCP"
  vpc_id   = "${local.vpc_id}"

  health_check {
    healthy_threshold   = 10
    unhealthy_threshold = 10
    interval            = 30
    protocol            = "TCP"
  }
  tags = {
    yor_trace = "797e47b6-c1b2-4475-9345-a24e5f5f56a9"
  }
}

# Listener for Ingestor
resource "aws_lb_listener" "logsearch_lb_5514" {
  load_balancer_arn = "${aws_lb.logsearch_lb.arn}"
  protocol          = "TCP"
  port              = 5514

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.logsearch_lb_5514.arn}"
  }
}

resource "aws_lb_target_group" "logsearch_lb_5514" {
  name     = "logsearch5514"
  port     = 5514
  protocol = "TCP"
  vpc_id   = "${local.vpc_id}"

  health_check {
    healthy_threshold   = 10
    unhealthy_threshold = 10
    interval            = 30
    protocol            = "TCP"
  }
  tags = {
    yor_trace = "84c7c9a6-baf0-4af7-9039-f817dc229caf"
  }
}

# Listener for Ingestor TLS
resource "aws_lb_listener" "logsearch_lb_6514" {
  load_balancer_arn = "${aws_lb.logsearch_lb.arn}"
  protocol          = "TCP"
  port              = 6514

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.logsearch_lb_6514.arn}"
  }
}

resource "aws_lb_target_group" "logsearch_lb_6514" {
  name     = "logsearch6514"
  port     = 6514
  protocol = "TCP"
  vpc_id   = "${local.vpc_id}"

  health_check {
    healthy_threshold   = 10
    unhealthy_threshold = 10
    interval            = 30
    protocol            = "TCP"
  }
  tags = {
    yor_trace = "cbf8c1eb-fdf4-496c-9554-c2a2dab20043"
  }
}

# Listener for RELP
resource "aws_lb_listener" "logsearch_lb_2514" {
  load_balancer_arn = "${aws_lb.logsearch_lb.arn}"
  protocol          = "TCP"
  port              = 2514

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.logsearch_lb_2514.arn}"
  }
}

resource "aws_lb_target_group" "logsearch_lb_2514" {
  name     = "logsearch2514"
  port     = 2514
  protocol = "TCP"
  vpc_id   = "${local.vpc_id}"

  health_check {
    healthy_threshold   = 10
    unhealthy_threshold = 10
    interval            = 30
    protocol            = "TCP"
  }
  tags = {
    yor_trace = "b7a6396b-64a3-464a-9078-8305007fa554"
  }
}

# Security group
resource "aws_security_group" "logsearch_lb_security_group" {
  name        = "logsearch-lb-security-group"
  description = "Logsearch"
  vpc_id      = "${local.vpc_id}"

  tags {
    Name = "${var.env_id}-logsearch-lb-internal-security-group"
  }

  lifecycle {
    ignore_changes = ["name"]
  }
  tags = {
    yor_trace = "f951e415-d633-466a-8529-247246b8cac8"
  }
}

# Security rules
resource "aws_security_group_rule" "logsearch_lb_80" {
  type        = "ingress"
  protocol    = "tcp"
  from_port   = 80
  to_port     = 80
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.logsearch_lb_security_group.id}"
}

resource "aws_security_group_rule" "logsearch_lb_8080" {
  type        = "ingress"
  protocol    = "tcp"
  from_port   = 8080
  to_port     = 8080
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.logsearch_lb_security_group.id}"
}

resource "aws_security_group_rule" "logsearch_lb_5514" {
  type        = "ingress"
  protocol    = "tcp"
  from_port   = 5514
  to_port     = 5514
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.logsearch_lb_security_group.id}"
}

resource "aws_security_group_rule" "logsearch_lb_6514" {
  type        = "ingress"
  protocol    = "tcp"
  from_port   = 6514
  to_port     = 6514
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.logsearch_lb_security_group.id}"
}

resource "aws_security_group_rule" "logsearch_lb_2514" {
  type        = "ingress"
  protocol    = "tcp"
  from_port   = 2514
  to_port     = 2514
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.logsearch_lb_security_group.id}"
}
