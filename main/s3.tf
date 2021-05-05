# S3 bucket for Kops states
resource aws_s3_bucket "kops_state_store" {
  bucket        = "lg-k8s-state-store"
  acl           = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    terraformed = "yes"
  }
}
