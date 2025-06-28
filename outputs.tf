output "ec2_public_ip" {
  value = aws_instance.dev.public_ip
}

output "private_key_path" {
  value     = local_file.private_key.filename
  sensitive = true
}

output "private_key_pem" {
  value     = tls_private_key.my_ec2key.private_key_pem
  sensitive = true # Sensitive to avoid printing the key in Terraform output
}