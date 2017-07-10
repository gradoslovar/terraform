provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

module "vpc" {
  source = "./vpc"

  # source = "git::https://github.com/XXX/tf_vpc.git?ref=dev/staging/production"
  name          = "web"
  cidr          = "192.168.0.0/16"
  public_subnet = "192.168.1.0/24"
}

resource "aws_instance" "base" {
  ami = "${lookup(var.ami, var.region)}"

  # var.ami[“us-west-1”]
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  subnet_id                   = "${module.vpc.public_subnet_id}"
  private_ip                  = "${var.ip_set[count.index]}"        # here we iterate throught the set of predifined ip's
  associate_public_ip_address = true
  user_data                   = "${file("files/web_bootstrap.sh")}"

  vpc_security_group_ids = [
    "${aws_security_group.web_host_sg.id}",
  ]

  count = "${length(var.ip_set)}" # count index for private ip's iteration

  tags {
    Name = "web-${format("%03d", count.index + 1)}"
  }
}

resource "aws_elb" "web" {
  name            = "web-elb"
  subnets         = ["${module.vpc.public_subnet_id}"]          # accessing the ouput from vpc module
  security_groups = ["${aws_security_group.web_inbound_sg.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  instances = ["${aws_instance.base.*.id}"] # here we use 'splat' to iterate to all the instances created above
}

resource "aws_security_group" "web_inbound_sg" {
  name        = "web_inbound"
  description = "Allow HTTP from Anywhere"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "web_host_sg" {
  name        = "web_host"
  description = "Allow SSH & HTTP to web hosts"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${module.vpc.cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
