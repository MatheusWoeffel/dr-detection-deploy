output "url" {
  value       = aws_ecr_repository.private_repository.repository_url
  description = "The Repository's url."
}