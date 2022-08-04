#AWS VPC
resource "aws_vpc" "test_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "test_vpc"
  }
}

#AWS Subnet for the VPC
resource "aws_subnet" "test_subnet" {
  vpc_id                  = aws_vpc.test_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1a"

  tags = {
    Name = "test_subnet"
  }
}

#AWS Internet Gateway
resource "aws_internet_gateway" "test_gw" {
  vpc_id = aws_vpc.test_vpc.id

  tags = {
    Name = "test_int_gw"
  }
}

#AWS Route Table
resource "aws_route_table" "test_rt_tbl" {
  vpc_id = aws_vpc.test_vpc.id

  tags = {
    Name = "test_rt"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.test_rt_tbl.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.test_gw.id
}

#AWS Route table association
resource "aws_route_table_association" "test_public_assoc" {
  subnet_id      = aws_subnet.test_subnet.id
  route_table_id = aws_route_table.test_rt_tbl.id
}

#AWS Security Grp
resource "aws_security_group" "test_sec_grp" {
  name        = "test_sg"
  description = "Test Security Group"
  vpc_id      = aws_vpc.test_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    description = "RDP"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    self = true
  }
  ingress {
    description ="SSH"
    from_port = 22
    to_port =22
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    self = true
  }
  

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#AWS Key Pair
resource "aws_key_pair" "test_kp"{
    key_name = "windows_key"
    public_key = file("~/.ssh/windows(2)_key.pub")
}

#AWS EIP
resource "aws_eip" "test_eIP"{
  instance = aws_instance.test_inst.id
}

output "eip"{
  value = aws_eip.test_eIP.id
}
#AWS Instance
resource "aws_instance" "test_inst"{
    ami = "ami-08e7239dc2220a91a"
    instance_type = "t2.micro"
    key_name = aws_key_pair.test_kp.id
    vpc_security_group_ids = [aws_security_group.test_sec_grp.id]
    subnet_id = aws_subnet.test_subnet.id   
#    user_data = file("userdata.tpl") 
    root_block_device{
        volume_size = 30
    }

    tags = {
        Name = "test_node"
    }
}
