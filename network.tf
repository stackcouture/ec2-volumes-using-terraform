data "aws_availability_zones" "available" {
  state = "available"
}

#create VPC
resource "aws_vpc" "dev" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Dev VPC"
  }
}
#create IG and attach to VPC
resource "aws_internet_gateway" "dev" {
  vpc_id = aws_vpc.dev.id
  tags = {
    Name = "dev-igw"
  }
}

#create subnet
resource "aws_subnet" "dev" {
  vpc_id                  = aws_vpc.dev.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "dev-public-subnet"
  }
}

#create route table and provide path IG to RT (edit routes)
resource "aws_route_table" "dev" {
  vpc_id = aws_vpc.dev.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev.id
  }
  tags = {
    Name = "dev-public-rt"
  }
}
#associate  RT to subnet
resource "aws_route_table_association" "dev" {
  route_table_id = aws_route_table.dev.id
  subnet_id      = aws_subnet.dev.id
}

resource "aws_security_group" "dev_sg" {
  name        = "dev-sg"
  description = "Allow HTTP, SSH, and custom app traffic"
  vpc_id      = aws_vpc.dev.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow App Traffic on Port 8080"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dev_sg"
  }

}