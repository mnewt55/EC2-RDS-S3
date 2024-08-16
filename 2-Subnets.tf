resource "aws_subnet" "public-eu-west-1a" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.32.1.0/24"
  availability_zone = "eu-west-1a"
}

resource "aws_subnet" "private-eu-west-1a" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.32.11.0/24"
  availability_zone = "eu-west-1a"
}

resource "aws_subnet" "private-eu-west-1b" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.32.12.0/24"
  availability_zone = "eu-west-1b"
}

