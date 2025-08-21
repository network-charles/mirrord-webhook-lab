data "aws_eks_cluster_auth" "staging" {
  name = "staging"
}

data "aws_route53_zone" "public" {
  name = "charlesuneze.click." # Ensure the domain name ends with a dot
}

################################

data "kubernetes_service" "ingress_nginx" {
  metadata {
    name = "ingress-nginx-controller"
  }

  depends_on = [
    aws_eks_cluster.staging,
    aws_eks_node_group.worker-node-group,
    helm_release.ingress_nginx
  ]
}

data "aws_lb_hosted_zone_id" "ingress_nginx" {}

################################

data "aws_iam_policy_document" "ecr" {
  statement {
    effect = "Allow"

    actions = [
      "ecr:CreateRepository",
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:GetAuthorizationToken",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
      "codecommit:GitPull"
    ]

    resources = ["*"]
  }
}
