resource "aws_db_subnet_group" "my_db_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = [aws_subnet.private-eu-west-1a.id, aws_subnet.private-eu-west-1b.id]

  tags = {
    Name = "My DB Subnet Group"
  }
}

resource "aws_db_instance" "my_db_instance" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0.35"
  instance_class       = "db.t3.micro"
  db_name              = "mydb"
  identifier           = "database-1"
  username             = "dbuser"
  password             = "dbpassword"
  parameter_group_name = "default.mysql8.0"
  publicly_accessible  = true
  multi_az             = false
  backup_retention_period = 0
  skip_final_snapshot = true

  vpc_security_group_ids = [aws_security_group.rds_sg.id] 
  db_subnet_group_name   = aws_db_subnet_group.my_db_subnet_group.name 

  tags = {
    Name = "MyDB"
  }

  timeouts {
    create = "60m"
    delete = "60m"
    update = "60m"
  }
}


#creating ec2 instance
resource "aws_instance" "ec2" {
    ami = "ami-08ca6be1dc85b0e84"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.public-eu-west-1a.id
    associate_public_ip_address = true
    key_name = "MyLinuxBox"
    tags = {
        Name = "EC2-for-RDS"
    }
    security_groups = [ aws_security_group.sg_for_ec2.id ]
}


# Define the S3 Bucket
resource "aws_s3_bucket" "my_s3_bucket" {
  bucket = "my-rds-s3-bucket-9104"

  tags = {
    Name = "My RDS S3 Bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "bucket_ownership" {
  bucket = aws_s3_bucket.my_s3_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "private_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.bucket_ownership]

  bucket = aws_s3_bucket.my_s3_bucket.id
  acl    = "private"
}

# Define the IAM Role for RDS to access S3
resource "aws_iam_role" "rds_s3_access_role" {
  name = "rds-s3-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "rds.amazonaws.com"
        }
      }
    ]
  })
}

# Attach a custom policy to the IAM Role to allow S3 access
resource "aws_iam_policy" "rds_s3_access_policy" {
  name        = "rds-s3-access-policy"
  description = "Policy to allow RDS to access S3 bucket"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject"
        ],
        Resource = [
          aws_s3_bucket.my_s3_bucket.arn,
          "${aws_s3_bucket.my_s3_bucket.arn}/*"
        ]
      }
    ]
  })
}

# Attach the policy to the IAM Role
resource "aws_iam_role_policy_attachment" "rds_s3_access_policy_attachment" {
  role       = aws_iam_role.rds_s3_access_role.name
  policy_arn = aws_iam_policy.rds_s3_access_policy.arn
}


