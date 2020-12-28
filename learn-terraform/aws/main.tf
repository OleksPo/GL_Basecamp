provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "aaz" {}

# Create a VPC 
resource "aws_vpc" "lbvpc" {
  cidr_block = "10.10.10.0/24"
}

# Create an internet gateway 
resource "aws_internet_gateway" "internetgw" {
  vpc_id = aws_vpc.lbvpc.id
}

# Assign internet access 
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.lbvpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internetgw.id
}

# Create a subnet to launch our instances into
resource "aws_subnet" "sn1" {
  vpc_id                  = aws_vpc.lbvpc.id
  cidr_block              = "10.10.10.0/25"
  availability_zone = data.aws_availability_zones.aaz.names[0]
  map_public_ip_on_launch = true
}

resource "aws_subnet" "sn2" {
  vpc_id                  = aws_vpc.lbvpc.id
  cidr_block              = "10.10.10.128/25"
    availability_zone = data.aws_availability_zones.aaz.names[1]
  map_public_ip_on_launch = true
}


# A security group for the ELB so it is accessible via the web
resource "aws_security_group" "elb" {
  name        = "terraform_example_elb"
  description = "Used in the terraform"
  vpc_id      = aws_vpc.lbvpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# For ssh access to instances
resource "aws_security_group" "fssh" {
  name        = "terraform_example"
  description = "Used in the terraform"
  vpc_id      = aws_vpc.lbvpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "web" {
  name = "terraform-example-elb"

  subnets         = [aws_subnet.sn1.id,
    aws_subnet.sn2.id]
  security_groups = [aws_security_group.elb.id]
  instances       = [aws_instance.web1.id,
    aws_instance.web2.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}

resource "aws_key_pair" "auth" {
  key_name   = var.key_name
  public_key = file(var.public_key_puth)
}

resource "aws_instance" "web1" {
  connection {
    user = "ubuntu"
    host = " "
  }

  instance_type = "t2.micro"

  ami = lookup(var.aws_amis, var.aws_region)

  key_name = aws_key_pair.auth.id

  vpc_security_group_ids = [aws_security_group.fssh.id]

  subnet_id = aws_subnet.sn1.id

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "sudo apt-get -y install nginx",
      "sudo service nginx start",
    ]
  }
}

resource "aws_instance" "web2" {
  connection {
    user = "ubuntu"
    host = ""
  }

  instance_type = "t2.micro"

  ami = lookup(var.aws_amis, var.aws_region)

  key_name = aws_key_pair.auth.id

  vpc_security_group_ids = [aws_security_group.fssh.id]

  subnet_id = aws_subnet.sn2.id

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "sudo apt-get -y install nginx",
      "sudo service nginx start",
    ]
  }
}
