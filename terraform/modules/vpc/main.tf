
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igw"
  }
}

resource "aws_subnet" "sub1" {
  cidr_block        = "10.0.1.0/24"
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnt1"
  }
}


resource "aws_subnet" "sub2" {
  cidr_block        = "10.0.2.0/24"
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnt2"
  }
}



resource "aws_db_subnet_group" "dbsubnet" {
  name       = "subnt_grp"
#   subnet_ids = [aws_subnet.sub1.id, aws_subnet.sub2.id, aws_subnet.sub3.id]
  subnet_ids = [aws_subnet.sub1.id, aws_subnet.sub2.id]
  tags = {
    Name = "subnt_grp"
  }
}

resource "aws_route_table" "rtb" {
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "rtb"
  }
}
resource "aws_route_table_association" "subnet-1-route-association" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.rtb.id
}
resource "aws_route_table_association" "subnet-2-route-association" {
  subnet_id      = aws_subnet.sub2.id
  route_table_id = aws_route_table.rtb.id
}

# /*
#   Public Subnet
# */
resource "aws_subnet" "subnet-public" {
  vpc_id = aws_vpc.vpc.id

  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public-subnt-public"
  }
}

resource "aws_route_table" "rtb-public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Public-rtb-public"
  }
}

resource "aws_route_table_association" "rtb-as-public" {
  subnet_id      = aws_subnet.subnet-public.id
  route_table_id = aws_route_table.rtb-public.id
}