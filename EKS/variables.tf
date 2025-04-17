variable "region" {
  description = "The AWS region to deploy the EKS cluster in"
  type        = string
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "The Kubernetes version to use for the EKS cluster"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "node_instance_type" {
  description = "EC2 instance type for the EKS nodes"
  type        = string
}

variable "node_desired_capacity" {
  description = "Desired number of worker nodes"
  type        = number
}

variable "node_max_capacity" {
  description = "Maximum number of worker nodes"
  type        = number
}

variable "node_min_capacity" {
  description = "Minimum number of worker nodes"
  type        = number
}

variable "key_pair" {
  description = "Key pair for SSH access to the EKS nodes"
  type        = string
}

variable "allowed_ips" {
  description = "List of IP addresses allowed to access the cluster"
  type        = list(string)
}

variable "cloudwatch_log_types" {
  description = "Types of control plane logs to send to CloudWatch"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "cloudwatch_log_retention_in_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 90
}

variable "tags" {
  description = "Common tags for resources"
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "production"  # You can set a default value or leave it without one
}

variable "public_subnet_count" {
  description = "Number of public subnet"
  type        = number
  default     = 2
}

variable "private_subnet_count" {
  description = "Number of private subnets"
  type        = number
  default     = 2
}

# Adding for IRSA and OICD
variable "namespace" {
  description = "The Kubernetes namespace where the service account will be created."
  type        = string
  default     = "irsa-ns"
}

variable "service_account_name" {
  description = "The name of the Kubernetes service account for IRSA."
  type        = string
  default     = "irsa-sa"
}

variable "s3_bucket_name" {
  description = "The name of existing S3 bucket for IRSA"
  type        = string
}
