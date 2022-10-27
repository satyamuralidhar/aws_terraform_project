//cretaing a virtual network 

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "${var.env}-vpc"
  }
}
//subnet creation of vnet
resource "aws_subnet" "subnet" {
  vpc_id = "${aws_vpc.main.id}"
  count = "${length(var.subnet)}"
  //element(list,index)
  cidr_block = "${element(var.subnet,count.index)}"
  map_public_ip_on_launch = "${aws_subnet.subnet.cidr_block[0] == true ? true : false}"
  tags = {
    "Name" = "subnet-${count.index+1}"
  }
  depends_on = [
    aws_vpc.main.id
  ]
}

// internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  depends_on = [
    aws_vpc.main,
    aws_subnet.subnet.cidr_block[0]
  ]
}
tags = merge(
  var.tagging 
)

//creating route table 

resource "aws_route_table" "route" {
  vpc_id = aws_vpc.example.id

  route {
    cidr_block = "${aws_subnet.subnet.cidr_block[0]}"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.gw.id
  }
  depends_on = [
    aws_vpc.main,
    aws_subnet.subnet.cidr_block[0],
    aws_internet_gateway.gw
  ]
}
//creating linux vm 
resource "aws_instance" "linux_instance" {
  ami = "${var.ami_id}"
  instance_type = "${var.instance_type}"
  subnet_id = aws_subnet.subnet.id
}
resource "aws_security_group" "allow_all" {
  name        = "allow_inbound"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "allow all trafic from VPC"
    from_port        = [80,8080]
    to_port          = [80,8080]
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.main.cidr_block]
    ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port        = [80,8080]
    to_port          = [80,8080]
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_traffic"
  }
  depends_on = [
    aws_internet_gateway.gw,
    aws_vpc.main.id,
    aws_subnet.subnet.cidr_block[0]
  ]
}
