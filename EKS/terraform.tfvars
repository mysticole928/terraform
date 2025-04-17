region                       = "aws-region-1"
cluster_name                 = "EKS-Cluster-Name-Goes-Here"
kubernetes_version           = "1.31"
vpc_cidr                     = "10.0.0.0/16"
node_instance_type           = "t3.medium"
node_desired_capacity        = 2
node_max_capacity            = 3
node_min_capacity            = 1
key_pair                     = "KEY-PAIR-NAME-GOES-HERE"
private_subnet_count = 2
public_subnet_count = 2
allowed_ips                  = ["999.999.99.999/32", "888.888.888.888/32"]
cloudwatch_log_types         = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
cloudwatch_log_retention_in_days = 90
s3_bucket_name = "S3-BUCKET-NAME-FOR-IRSA"

tags = {
  "Owner"   = "Owner Name"
  "Email"   = "owner.name@example.com"
}

# Added for IRSA

namespace             = "irsa-namespace"
service_account_name  = "irsa-service-account"
