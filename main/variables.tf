variable "access_key" {}

variable "secret_key" {}

variable "region" {
  type    = string
  default = "us-west-1"
}

variable "k8s_version" {
  type    = string
  default = "1.20.6"
}

variable "k8s_access_cidr" {
  description = "List of API addresses from which K8S cluster should be accessed"
  type        = list(string)
  default     = ["172.23.0.0/18"]
}

variable "k8s_ami_id" {
  type    = string
  default = "ami-08b539bf912b04c45"
}

variable "k8s_cluster_name" {
  type      = string
  default   = "lg.k8s.com"
}
# default: false/empty
variable "vpc_generic_cidr_base" {
  type      = string
  default   = "172.23.0.0"
}
variable "vpc_generic_azs" {
  description = "Availability Zones in the configured region"
  type        = list(string)
  default     = ["us-west-1a", "us-west-1b", "us-west-1c"]
}
# By default, place the nat-gw in the first AZ's public subnet
variable "vpc_natgw_az_index" {
  default     = 0
}