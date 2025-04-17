# Generate the unique S3 bucket name based on the datestamp
locals {
  timestamp = formatdate("060102150405", timestamp())
}

# Convert cluster_name to lowercase to meet S3 bucket naming conventions
locals {
  normalized_cluster_name = lower(replace(var.cluster_name, "/[^a-zA-Z0-9-]/", "-"))
}

# S3 Bucket Policy to allow access
resource "aws_s3_bucket_policy" "irsa_bucket_policy" {
  bucket = var.s3_bucket_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowIAMUserAccess"
        Effect    = "Allow"
        Principal = {
          AWS = aws_iam_role.irsa_role.arn  # Ensure this references the correct IRSA role from iam.tf
        }
        Action    = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource  = [
          "arn:aws:s3:::${var.s3_bucket_name}/${var.cluster_name}/*"  # Using cluster name as prefix
        ]
      }
    ]
  })

  depends_on = [aws_iam_role.irsa_role]  # Ensure that the IRSA role is created before the policy is applied
}
