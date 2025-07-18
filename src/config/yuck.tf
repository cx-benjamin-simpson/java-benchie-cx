provider "aws" {
  region     = "us-east-1"
  access_key = "AKIA_FAKE_ACCESS_KEY"
  secret_key = "very-secret-fake-key"
}

##################
# S3 MISCONFIGS
##################

# S3 Bucket With All Permissions – a4966c4f
resource "aws_s3_bucket_policy" "all_perms" {
  bucket = aws_s3_bucket.insecure.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid       = "AllowAllActions"
      Effect    = "Allow"
      Principal = "*"
      Action    = "*"
      Resource  = [
        "arn:aws:s3:::${aws_s3_bucket.insecure.id}",
        "arn:aws:s3:::${aws_s3_bucket.insecure.id}/*"
      ]
    }]
  })
}

# OSS Bucket Allows All Actions From All Principals – ec62a32c
resource "aws_s3_bucket" "insecure" {
  bucket = "oss-bucket-open-access"
  acl    = "public-read-write"
}

# S3 Bucket ACL Grants WRITE_ACP – 64a222aa
resource "aws_s3_bucket_acl" "write_acp" {
  bucket = aws_s3_bucket.insecure.id
  acl    = "authenticated-read"
}

# S3 Bucket Allows Delete Action From All Principals – ffdf4b37
resource "aws_s3_bucket_policy" "delete_all" {
  bucket = aws_s3_bucket.insecure.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid       = "AllowDelete"
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:DeleteObject"
      Resource  = "arn:aws:s3:::oss-bucket-open-access/*"
    }]
  })
}

# S3 Bucket Allows Put Action From All Principals – d24c0755
resource "aws_s3_bucket_policy" "put_all" {
  bucket = aws_s3_bucket.insecure.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid       = "AllowPut"
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:PutObject"
      Resource  = "arn:aws:s3:::oss-bucket-open-access/*"
    }]
  })
}

##################
# RDS MISCONFIGS
##################

# RDS DB Instance Publicly Accessible – faaefc15 / 35113e6f
resource "aws_db_instance" "insecure_rds" {
  identifier         = "open-rds"
  engine             = "mysql"
  username           = "admin"
  password           = "Plaintext123"
  instance_class     = "db.t2.micro"
  allocated_storage  = 20
  publicly_accessible = true
  skip_final_snapshot = true
}

# DB Security Group With Public Scope – 1e0ef61b
resource "aws_security_group" "rds_sg" {
  name        = "rds-open-sg"
  description = "open to world"
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS Associated with Public Subnet – 2f737336
resource "aws_db_subnet_group" "public_subnet_group" {
  name       = "public-subnet"
  subnet_ids = ["subnet-abc123"] # Assume subnet is public
}

##################
# DMS, ECR, SNS, REDIS, SQL
##################

# Amazon DMS Replication Instance Is Publicly Accessible – 030d3b18
resource "aws_dms_replication_instance" "open_dms" {
  replication_instance_id     = "open-dms"
  replication_instance_class  = "dms.t2.micro"
  publicly_accessible         = true
  allocated_storage           = 20
}

# ECR Repository Is Publicly Accessible – e86e26fc
resource "aws_ecr_repository_policy" "ecr_public" {
  repository = aws_ecr_repository.insecure.name
  policy = jsonencode({
    Version = "2008-10-17",
    Statement = [{
      Sid       = "AllowAll"
      Effect    = "Allow"
      Principal = "*"
      Action    = "*"
    }]
  })
}

resource "aws_ecr_repository" "insecure" {
  name = "public-ecr-repo"
}

# SNS Topic is Publicly Accessible – b26d2b7e
resource "aws_sns_topic_policy" "sns_public" {
  arn = aws_sns_topic.insecure.arn
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid       = "PublicAccess"
      Effect    = "Allow"
      Principal = "*"
      Action    = "SNS:Publish"
      Resource  = aws_sns_topic.insecure.arn
    }]
  })
}

resource "aws_sns_topic" "insecure" {
  name = "public-sns"
}

# Redis Publicly Accessible – 5089d055
resource "aws_elasticache_replication_group" "redis_open" {
  replication_group_id       = "redis-group"
  replication_group_description = "Open Redis"
  engine                     = "redis"
  node_type                  = "cache.t2.micro"
  number_cache_clusters      = 1
  automatic_failover_enabled = false
  security_group_ids         = [aws_security_group.redis_sg.id]
}

resource "aws_security_group" "redis_sg" {
  name        = "redis-sg"
  description = "open redis"
  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# SQLServer Ingress From Any IP – 25c0ea09
resource "aws_security_group" "sql_sg" {
  name        = "sql-sg"
  description = "Open SQL Server"
  ingress {
    from_port   = 1433
    to_port     = 1433
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# SQL DB Instance Publicly Accessible – b187edca
resource "aws_db_instance" "sql_open" {
  identifier         = "sql-open"
  engine             = "sqlserver-ex"
  username           = "admin"
  password           = "InsecurePassword123"
  instance_class     = "db.t3.medium"
  publicly_accessible = true
  allocated_storage  = 20
  skip_final_snapshot = true
}

##################
# OBSERVABILITY + GCP + AZURE
##################

# CloudWatch Unauthorized Access Alarm Missing – 4c18a45b
# This is omitted on purpose (lack of metric alarms)

# Cloud Storage Anonymous or Publicly Accessible – a6cd52a1 (GCP)
# Would apply to google_storage_bucket IAM policy (not AWS)

# CosmosDB Account IP Range Filter Not Set – c2a3efb6 (Azure)
# Would apply to `azurerm_cosmosdb_account.ip_range_filter = ""`
