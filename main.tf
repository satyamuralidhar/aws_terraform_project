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
  availability_zone = "${element(var.azs,count.index)}"
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
//creating route table 

resource "aws_route_table" "route" {
  vpc_id = aws_vpc.example.id

  route {
    cidr_block = "0.0.0.0/0"
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

resource "aws_route_table_association" "table_association" {
  count = length(var.subnet)
  subnet_id = "${element(aws_subnet.subnet[0].id)}"
  route_table_id = "${aws_route_table.route.id}"
  gateway_id = "${aws_internet_gateway.gw.id}"
}

// internet gatewayss
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

//creating linux vm 
resource "aws_instance" "linux_instance" {
  ami = "${var.ami_id}"
  instance_type = "${var.instance_type}"
  subnet_id = aws_subnet.subnet.id
  associate_public_ip_address = true
}

resource "aws_security_group" "allow_all" {
  name        = "allow_inbound"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "allow all trafic from VPC"
    from_port        = [22,80,8080]
    to_port          = [22,80,8080]
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.main.cidr_block]
    ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port        = [22,80,8080]
    to_port          = [22,80,8080]
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(
    var.tagging,
    {
    Name = "allow_traffic"
    }
  )
  depends_on = [
    aws_internet_gateway.gw,
    aws_vpc.main.id,
    aws_subnet.subnet.cidr_block[0]
  ]
}
resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
#create a key form aws 

resource "aws_key_pair" "kp" {
  key_name   = "myKey"  
  public_key = tls_private_key.pk.public_key_openssh

  provisioner "local-exec" { 
    command = "echo '${tls_private_key.pk.private_key_pem}' > ./keys/myKey.pem"
    on_failure = fail
  }
}
resource "null_resource" "permissions" {
  provisioner "local-exec" {
    command = "chmod 400 ./keys/myKey.pem"
    on_failure = fail
  }
  
}
#create a webserver nginx
connection {
    type = "ssh"
    user = "ec2-user"
    private_key = file("./keys/myKey.pem")
    host = self.public_ip
  }

provisioner "remote-exec" {
  inline = [
      "echo hello",
      "set",
      "pwd",
      "sudo yum update",
      "sudo yum install nginx -y"
  ]
}
