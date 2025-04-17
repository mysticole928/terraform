# Retrieve EKS-Optimized AMI ID for Amazon Linux 2023
data "aws_ssm_parameter" "eks_ami" {
  name = "/aws/service/eks/optimized-ami/${var.kubernetes_version}/amazon-linux-2023/x86_64/standard/recommended/image_id"
}

# EKS Node Group Configuration
resource "aws_eks_node_group" "eks_nodes" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = aws_subnet.private[*].id

  scaling_config {
    desired_size = var.node_desired_capacity
    max_size     = var.node_max_capacity
    min_size     = var.node_min_capacity
  }

  instance_types = [var.node_instance_type]

  launch_template {
    id      = aws_launch_template.eks_node_template.id
    version = "$Latest"
  }

  tags = var.tags
}

# Launch Template for EKS Node Group with Cloud-Init YAML User-Data Script
resource "aws_launch_template" "eks_node_template" {
  name = "${var.cluster_name}-node-template"

  user_data = base64encode(<<-EOT
    MIME-Version: 1.0
    Content-Type: multipart/mixed; boundary="==BOUNDARY=="

    --==BOUNDARY==
    Content-Type: text/cloud-config; charset="us-ascii"

    #cloud-config
    write_files:
      - path: /etc/eks/nodeconfig.yaml
        content: |
          apiVersion: node.eks.aws/v1alpha1
          kind: NodeConfig
          spec:
            cluster:
              name: ${var.cluster_name}
              apiServerEndpoint: ${aws_eks_cluster.eks.endpoint}
              certificateAuthority: ${aws_eks_cluster.eks.certificate_authority.0.data}
              cidr: ${aws_eks_cluster.eks.kubernetes_network_config.0.service_ipv4_cidr}

    --==BOUNDARY==
    Content-Type: text/x-shellscript; charset="us-ascii"

    #!/bin/bash
    set -o xtrace

    # Run nodeadm to apply the node configuration
    /usr/bin/nodeadm init --config-source file:///etc/eks/nodeconfig.yaml >> /var/log/nodeadm.log 2>&1

    # Ensure SSM agent is running
    sudo systemctl enable amazon-ssm-agent
    sudo systemctl start amazon-ssm-agent

    --==BOUNDARY==--
  EOT
  )

  key_name = var.key_pair
  image_id = data.aws_ssm_parameter.eks_ami.value  # AMI retrieved from SSM

  network_interfaces {
    security_groups             = [aws_security_group.eks_node.id]
    associate_public_ip_address = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = var.tags
  }
}
