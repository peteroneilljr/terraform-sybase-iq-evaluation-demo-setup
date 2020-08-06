
#################
# Security Group
#################
module "sg_sybase_iq" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "sg_sybase_iq"
  description = "Security group for Sybase IQ - publicly open"
  vpc_id      = data.aws_vpc.selected.id

  egress_rules        = ["all-all"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = var.sybase_iq_port
      to_port     = var.sybase_iq_port
      protocol    = "tcp"
      description = "Sybase IQ"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

#################
# IAM profile to download from S3
#################
resource "aws_iam_instance_profile" "sybase_iq" {
  name_prefix = "sybase_iq"
  role = aws_iam_role.sybase_iq.name
}

resource "aws_iam_role" "sybase_iq" {
  name_prefix = "sybase_iq"
  path        = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
resource "aws_iam_role_policy" "sybase_iq" {
  name = "sybase_iq"
  role = aws_iam_role.sybase_iq.id

  policy = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:Get*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
  EOF
}

#################
# RHEL 7.2 is a supported version for Sybase IQ
#################
data "aws_ami" "rhel_7_2" {
  # RedHat 
  most_recent = true
  owners      = ["309956199498"]

  filter {
    name   = "state"
    values = ["available"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "name"
    values = ["RHEL-7.2*"]
  }
}


#################
# sybase setup
#################

data "template_cloudinit_config" "sybase_iq" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "sybase_iq_setup.cfg"
    content_type = "text/cloud-config"
    content      = local.iq_cloud_config
  }
}

resource "aws_instance" "sybase_iq" {
  ami           = data.aws_ami.rhel_7_2.image_id
  instance_type = var.sybase_iq_ec2_size
  key_name      = var.sybase_iq_aws_key_name
  monitoring    = var.sybase_iq_ec2_assign_public_ip

  # takes about 15 min to fully install Sybase IQ
  user_data_base64 = data.template_cloudinit_config.sybase_iq.rendered

  root_block_device {
    volume_size = 20
  }

  iam_instance_profile = aws_iam_instance_profile.sybase_iq.name

  subnet_id                   = data.aws_subnet.selected.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [module.sg_sybase_iq.this_security_group_id]

  lifecycle {
    ignore_changes = [
      ami,
    ]
  }

  tags = merge({ "Name" = "Sybase IQ" }, var.default_tags)
}
