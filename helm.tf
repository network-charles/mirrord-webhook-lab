resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.13.1"

  depends_on = [
    aws_eks_cluster.staging,
    aws_eks_node_group.worker-node-group
  ]
}
