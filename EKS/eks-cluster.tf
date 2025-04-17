# EKS Cluster

resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn

  version = var.kubernetes_version

  vpc_config {
    subnet_ids             = aws_subnet.private[*].id
    endpoint_public_access = true   # Enable public access to the EKS API server
    endpoint_private_access = true  # Enable private access to the EKS API server
    public_access_cidrs    = ["0.0.0.0/0"]  # EKS API accessible from anywhere

    # Reference the security group for the EKS cluster
    security_group_ids = [aws_security_group.eks_cluster.id]
  }

  enabled_cluster_log_types = var.cloudwatch_log_types

  tags = var.tags
}

# EKS VPC CNI Addon
resource "aws_eks_addon" "vpc_cni_addon" {
  cluster_name = aws_eks_cluster.eks.name
  addon_name   = "vpc-cni"

  configuration_values = jsonencode({
    env = {
      ENABLE_POD_ENI                    = "true"
      ENABLE_PREFIX_DELEGATION          = "true"
      POD_SECURITY_GROUP_ENFORCING_MODE = "standard"
    }
  })

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "vpc-cni-addon"
  }
}

# OpenID Connect (OIDC) Provider for EKS
data "aws_eks_cluster" "eks" {
  name = aws_eks_cluster.eks.name

  depends_on = [ aws_eks_cluster.eks ]
}

data "tls_certificate" "eks_oidc_thumbprint" {
  url = "https://${replace(data.aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")}"
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [element(split(":", data.tls_certificate.eks_oidc_thumbprint.certificates[0].sha1_fingerprint), 1)]
  url             = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer

  tags = var.tags
}
