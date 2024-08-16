resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Security group for RDS instance"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [ aws_security_group.sg_for_ec2.id ]  # Allow traffic from the EC2 instance
  }

  tags = {
    Name = "rds-sg"
  }
}