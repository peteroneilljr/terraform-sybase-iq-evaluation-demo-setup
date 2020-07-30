# Readme for Sybase IQ Terraform Module

```hcl
module "sybase_iq" {
  source = modules/sybase_iq

  sybase_iq_port = 2638
  sybase_iq_db_admin = "DBA"
  sybase_iq_ssh_key = "ssh-rsa AAAAkey"
  sybase_iq_s3_link = "s3://bucket/name/Linux64-iq1610sp03_eval.tgz"
  sybase_iq_install_path = "/opt/sap"
  sybase_iq_ec2_size = "t2.medium"
  sybase_iq_ec2_assign_public_ip = false
  sybase_iq_aws_key_name = "key-pair"
  sybase_iq_linux_username = "sybuser"
  sybase_iq_linux_usergroup = "sybdba"
  vpc_id = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnets[0]

  default_tags = var.default_tags
}

resource "sdm_resource" "sybase_iq" {
  sybase_iq {
    name     = "aws_sybase_iq"
    hostname = module.sybase_iq.sybase_iq_private_hostname
    username = module.sybase_iq.sybase_iq_db_admin
    password = module.sybase_iq.sybase_iq_password
    port     = module.sybase_iq.sybase_iq_port

    tags = var.default_tags
  }
}
resource "sdm_role_grant" "sybase_iq" {
  role_id     = sdm_role.databases.id
  resource_id = sdm_resource.sybase_iq.id
}
```
