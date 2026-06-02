
resource "aws_vpc" "vpc_01" {
  cidr_block = "192.168.0.0/16"

  tags = {
    Name = "vpc-01"
  }
}

resource "aws_subnet" "sub_01" {
  vpc_id                  = aws_vpc.vpc_01.id
  cidr_block              = "192.168.0.0/20"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-Subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_01.id

  tags = {
    Name = "tf-vpc-01-igw"
  }
}

resource "aws_route_table" "rt_01" {
  vpc_id = aws_vpc.vpc_01.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "rtw_public"
  }
}

resource "aws_route_table_association" "rtw_01" {
  route_table_id = aws_route_table.rt_01.id
  subnet_id      = aws_subnet.sub_01.id
}

resource "aws_security_group" "sg" {
  name   = "tf-vpc-01-sg"
  vpc_id = aws_vpc.vpc_01.id

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
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "vm_01" {
  ami           = "ami-07a00cf47dbbc844c"
  instance_type = "t3.micro"
  key_name      = "mumbai-practice"

  subnet_id = aws_subnet.sub_01.id

  vpc_security_group_ids = [
    aws_security_group.sg.id
  ]

  tags = {
    Name = "server-01"
  }
}
