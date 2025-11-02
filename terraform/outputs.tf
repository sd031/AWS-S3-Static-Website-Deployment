output "website_endpoint" {
  description = "Website endpoint URL"
  value       = aws_s3_bucket_website_configuration.website.website_endpoint
}

output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.website.id
}

output "website_url" {
  description = "Full website URL"
  value       = "http://${aws_s3_bucket_website_configuration.website.website_endpoint}"
}
