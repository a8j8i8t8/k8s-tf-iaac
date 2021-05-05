resource "aws_route53_zone" "k8s_cluster_zone" {
  name = var.k8s_cluster_name

  tags = {
    "terraformed" = "yes"
  }
}

resource "aws_acm_certificate" "k8s_cluster_cert" {
  domain_name       = var.k8s_cluster_name
  validation_method = "DNS"

  tags = {
    "terraformed" = "yes"
  }

  lifecycle {
    create_before_destroy = true
  }
}