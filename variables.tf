resource "random_password" "sybase_iq" {
  length           = 6
  special          = true
  override_special = "_%@"
}
variable "sybase_iq_port" {
  type    = number
  default = 2638
}
variable "sybase_iq_db_admin" {
  type    = string
  default = "DBA"
}
variable "sybase_iq_linux_username" {
  type    = string
  default = "sybuser"
}
variable "sybase_iq_linux_usergroup" {
  type    = string
  default = "sybdba"
}
variable "sybase_iq_ssh_key" {
  type    = string
  default = "ssh-rsa null"
}
variable "sybase_iq_s3_link" {
  type = string
}
variable "sybase_iq_install_path" {
  type    = string
  default = "/opt/sap"
}
variable "sybase_iq_ec2_size" {
  type    = string
  default = "t2.medium"
}
variable "sybase_iq_ec2_assign_public_ip" {
  type    = bool
  default = false
}
variable "sybase_iq_aws_key_name" {
  type    = string
  default = null
}
variable "default_tags" {
  type = map
  default = {
    "CreatedBy" = "Terraform"
  }
}
variable "vpc_id" {
  type        = string
  description = "vpc to deploy intp"
}
variable "subnet_id" {
  type        = string
  description = "subnet to deploy into"
}
data "aws_vpc" "selected" {
  id = var.vpc_id
}
data "aws_subnet" "selected" {
  id = var.subnet_id
}
