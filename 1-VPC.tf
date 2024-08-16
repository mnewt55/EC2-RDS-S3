resource "aws_vpc" "my_vpc" {
  cidr_block = "10.32.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}


