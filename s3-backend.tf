resource "random_id" "random" {
  byte_length = 2
}
//s3 bucket for tfstate
resource "aws_s3_bucket" "bucketname" {
  bucket = "${var.prefix}-bucket"

  tags = merge(
    var.tagging,
    {
        Name = "${random_id.random.dec}-bucket"
    }
  )
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.bucketname.id
  acl    = "private"
}
depends_on = [
    "${aws_s3_bucket.bucket_name.bucket}"
]

//creating dynamodb table for tf state locking
resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
  name = "${var.prefix}-tf-table"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20
 
  attribute {
    name = "LockID"
    type = "S"
  }
}
//backend
terraform {
  backend "s3" {
    bucket = "${aws_s3_bucket.bucketname.bucket}"
    dynamodb_table = "${aws_dynamodb_table.dynamodb-terraform-state-lock.name}"
    key    = "${aws_s3_bucket.bucketname.bucket}/*"
    region = "${var.location}"
  }
}