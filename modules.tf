terraform {
  backend "consul" {
      address = "demo.consul.io"
      path = "terraform-schoolofnet"
      lock = false
      scheme = "https"
  } 

}

provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region = "${var.region}"
}

data "aws_vpc" "vpc_default" {
  default = "true"
}

data "aws_subnet_ids" "id_default" {
  vpc_id = "${data.aws_vpc.vpc_default.id}"
}

module "s3-buckets" {
  source      = "devops-workflow/s3-buckets/aws"
  names       = ["test-s3-terraform"]
  environment = "dev"
  organization         = "corp"
}

  module "security_group" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "fw-terraform"
  description = "Security group for user-service with custom ports open within VPC, and PostgreSQL publicly open"
  vpc_id      = "${data.aws_vpc.vpc_default.id}"

  ingress_cidr_blocks      = ["0.0.0.0/0"]
  ingress_rules            = ["http-80-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "acesso-ssh"
      cidr_blocks = "0.0.0.0/0"
    }],
    egress_rules = ["all-all"]
  }

resource "aws_eip" "ip_publico" {
  vpc = "true"  
  instance   = "${module.ec2-instance.id[0]}"
}

resource "aws_key_pair" "acesso_ssh" {
  key_name   = "acesso_ssh"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/XSDONYjIa7UoIQwNs53aKB8V/R3dlkjwSr8FeEmWVsV/+aKivQ1RtpuwikzoZGD1HZXZ3mxML/2bLhbA8jtE1fBxFlwXOO0zg6hoXk/gMy7p1ouC+Qm9+3H8gBBkdOZjcE2H/ghiwx1ouI28Lqvt5qFvILx6mEH3b7KsZRMBJkSqsAb1/mjc7RgE6YHmU0PxrdJ9/vCizVSjnGWzb82yolukFy3yPZJmiUuftYx0Me4MN/vbZd62QmcuHOUIqSwPzj7TxkFlnHHejkvZCtT8m8Om5oC4zlhB8j8AUNNqf8GhIHY7rRxYzqOyEbEU5fLLNw5bMZ5CHTGIS377hvGF Jackson@LAPTOP-ULMI5ORS"
}
module "ec2-instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "1.13.0"

  name = "ec2-module"
  ami  = "ami-059eeca93cf09eebd"
  subnet_id = "${element(data.aws_subnet_ids.id_default.ids, 0)}"
  vpc_security_group_ids = ["${module.security_group.this_security_group_id}"]
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.acesso_ssh.key_name}"
}