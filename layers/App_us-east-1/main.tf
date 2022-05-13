#
#

terraform {
  required_version = ">= 0.13"
}


provider "aws" {
  version    = "~> 3.0"
  region     = var.region
  access_key = ""
  secret_key = ""
}



resource "aws_security_group" "sg_db_rds" {
  name        = "sg_db_rds"
  description = "Security Group for rds"
  vpc_id      = data.terraform_remote_state.base_networking.outputs.vpc_id

  tags = {
    "Name"            = "sg_rds_allow_3306"
    "ServiceProvider" = "JABJ-Clip"
    "Terraform"           = "True"
  }
}

resource "aws_security_group_rule" "rds_db_inbound_3306" {
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 3306
  to_port                  = 3306
  security_group_id        = aws_security_group.sg_db_rds.id
  cidr_blocks              = ["192.168.0.0/16"]
  description              = "Inbound for requests from VPC"
}

resource "aws_security_group_rule" "rds_clip_outbound" {
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  security_group_id = aws_security_group.sg_db_rds.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Outbound for all for request"
}


resource "aws_db_subnet_group" "clip-rds" {
  name        = "clip_subnet_group"
  description = "Clip Subnet Group"
  subnet_ids  = ["var.subnet_private1_id", "var.subnet_private2_id"]
}

resource "random_password" "rds_password" {
  length  = 21
  special = false
}

resource "aws_ssm_parameter" "rds_password" {
  name  = "/clip-dev/rds/clipDB"
  value = random_password.rds_password.result
  type  = "SecureString"
}

resource "aws_db_parameter_group" "rds_parameter_group" {
  name        = "clip-parameter-group"
  description = "clip DB Parameter Group"
  family      = "mysql5.7"
}


resource "aws_db_instance" "db-clip" {
  identifier               = "clip-dev"
  allocated_storage        = "20"
  engine                   = "mysql"
  engine_version           = "5.7"
  instance_class           = "db.t3.large"
  name                     = "store"
  username                 = "dbadmin"
  password                 = aws_ssm_parameter.rds_password
  port                     = 3306
  vpc_security_group_ids   = ["${aws_security_group.sg_db_rds.id}"]
  db_subnet_group_name     = aws_db_subnet_group.clip-rds.id
  parameter_group_name     = aws_db_parameter_group.rds_parameter_group
  multi_az                 = "true"
  publicly_accessible      = "true"
  storage_encrypted        = "true"
  skip_final_snapshot      = "true"
}



### Security Group EC2 
resource "aws_security_group" "ec2_sg" {

  name        = "ec2_sg"
  description = "Allow inbound traffic"
  vpc_id      = var.net_vpc_id

  tags = {
    Name = "Security group for ec2 instance"
    "ServiceProvider" = "JABJ-Clip"
    "Terraform"           = "True"
  }


}

resource "aws_security_group_rule" "ac_ec2_ingress_0" {
  type              = "ingress"
  description       = "HTTP Access"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.ec2_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ac_ec2_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2_sg.id
}

# Security Group ELB 
resource "aws_security_group" "web_sg" {

  name        = "web_sg"
  description = "Allow inbound traffic"
  vpc_id      = var.net_vpc_id

  tags = {
    Name = "Security group for ELB instance"
    "ServiceProvider" = "JABJ-Clip"
    "Terraform"           = "True"
  }


}

resource "aws_security_group_rule" "web_sg_ingress_80" {
  type              = "ingress"
  description       = "HTTP access"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.web_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "web_sg_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_sg.id
}

# Launch Configuration
resource "aws_launch_configuration" "web" {
  name_prefix = "web-jabj-App"

  image_id      = var.ami_amazonlinux2 # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type = "t2.micro"
  key_name      = "app_key"

  security_groups             = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
                #! /bin/bash
                cd /tmp
                sudo -i
                yum update -y
                yum install -y httpd httpd-tools mod_ssl
                amazon-linux-extras enable php7.4
                yum clean metadata
                yum install php php-common php-pear -y
                yum install php-{cgi,curl,mbstring,gd,mysqlnd,gettext,json,xml,fpm,intl,zip} -y
                echo "<?php print \"Hello World! -- ServerIP:\".\$_SERVER['SERVER_ADDR'] ?>" > /var/www/html/index.php
                mv /usr/sbin/suexec /usr/sbin/suexec.unused
                systemctl enable httpd
                systemctl start httpd
                echo "end!"              
   EOF

}

# Load Balancer
resource "aws_lb" "web_lb" {
  name = "web-lb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups = [aws_security_group.web_sg.id]
  subnets = [var.subnet_public1_id, var.subnet_public2_id]
  enable_deletion_protection = true
  tags = {
    Name = "web-lb"
    "ServiceProvider" = "JABJ-Clip"
    "Terraform"           = "True"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:80/"
  }

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = "80"
    instance_protocol = "http"
  }

}

output "elb_dns_name" {
  value = aws_lb.web_lb.dns_name
}

#Auto Scaling Group

resource "aws_autoscaling_group" "web_app" {
  name = "${aws_launch_configuration.web_app.name}-asg"

  min_size         = 2
  desired_capacity = 2
  max_size         = 4

  health_check_type = "ELB"
  load_balancers = [
    aws_elb.web_elb.id
  ]

  launch_configuration = aws_launch_configuration.web_app.name

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity = "1Minute"

  vpc_zone_identifier = [
    var.subnet_public1_id,
    var.subnet_public2_id
  ]

  # Required to redeploy without an outage.
  
  tag {
    key                 = "Name"
    value               = "web_app"
    propagate_at_launch = true
  }

}

