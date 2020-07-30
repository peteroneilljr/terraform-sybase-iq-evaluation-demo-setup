# Readme for Sybase IQ Terraform Module

```hcl
module "sybase_iq" {
  source = modules/sybase_iq

  sybase_iq_port = 2638
  sybase_iq_db_admin = "DBA"
  sybase_iq_ssh_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCUr6vcQp5pdtB96deXJ1RC/GupG3y+NFYu/GJLHfVZfuMp8c5kUWAw/VBLO+kJHHmQQRz21olWnPvx+URnElccbfuEohu59183/lRh1dXbp7oOD/ffZjnBzMHqAuVFc6ruyO1qFnLZdGdCJFM/1JKPp1ujj4RzbZC7MN94QE89Jqsx/duGOB4HUpPYH1793U0DOXGqygMbohV0EYPtb7u5NOs0KG1tiJ6x+BEv+HfQ554Ez28BqCuO/Iiiz4QW5PgjABS+iCH9+Wfc7LXz8Hm6gELHGDNFYjrAVE0BQfj2HPhTRNoXC4gVlBRK2z+hWYbqzWV5esNwwBfIax2+CA6h"
  sybase_iq_s3_link = "s3://peter-storing-stuff-to-download/Sybase-IQ-Linux64-iq1610sp03_eval.tgz"
  sybase_iq_install_path = "/opt/sap"
  sybase_iq_ec2_size = "t2.medium"
  sybase_iq_ec2_assign_public_ip = false
  sybase_iq_aws_key_name = "peter-pair"
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
