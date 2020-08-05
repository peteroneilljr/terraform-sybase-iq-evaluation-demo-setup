output "sybase_iq_public_ip" {
  value = var.sybase_iq_ec2_assign_public_ip ? aws_instance.sybase_iq.public_ip : "none"
}
output "sybase_iq_private_hostname" {
  value = aws_instance.sybase_iq.private_dns
}
output "sybase_iq_db_admin" {
  value = var.sybase_iq_db_admin
}
output "sybase_iq_password" {
  value = random_password.sybase_iq.result
}
output "sybase_iq_port" {
  value = var.sybase_iq_port
}