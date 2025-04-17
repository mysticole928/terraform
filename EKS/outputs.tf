# Define the local variable in the same file
locals {
  creation_time = formatdate("YYYY-MM-DD hh:mm:ss", timestamp())
}

# Output the human-readable timestamp
output "creation_time" {
  description = "The creation time of the resources in a readable format"
  value       = local.creation_time
}

output "eks_cluster_id" {
  value = aws_eks_cluster.eks.id
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

output "eks_cluster_security_group_id" {
  value = aws_security_group.eks_cluster.id
}
