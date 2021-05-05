#
# Outputs
#
output "k8s_cluster_name" {
    value = var.k8s_cluster_name
}

output "k8s_version" {
    value = var.k8s_version
}

output "k8s_ami_id" {
    value = var.k8s_ami_id
}

output "k8s_access_cidr" {
    value = [var.k8s_access_cidr]
}

output "kops_state_store" {
    value = aws_s3_bucket.kops_state_store
}

output "k8s_cluster_zone_id" {
    value = aws_route53_zone.k8s_cluster_zone.zone_id
}

output "k8s_cluster_cert_arn" {
    value = aws_acm_certificate.k8s_cluster_cert.arn
}

output "region" {
  value = var.region
}

output "vpc_id" {
  value = aws_vpc.primary-vpc.id
}

output "vpc_cidr" {
  value = aws_vpc.primary-vpc.cidr_block
}

output "vpc_generic_azs" {
    value = [var.vpc_generic_azs]
}

output "nat_gw_eip" {
  value = aws_eip.natgw.public_ip
}

output "public_subnet_ids" {
  value = aws_subnet.public-subnet.*.id
}

output "public_routetable_id" {
  value = aws_route_table.public-routing-table.id
}

output "nat_subnet_ids" {
  value = aws_subnet.nat-subnet.*.id
}

output "nat_routetable_id" {
  value = aws_route_table.nat-routing-table.id
}