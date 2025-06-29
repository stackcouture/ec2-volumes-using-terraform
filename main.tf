data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}

resource "aws_instance" "dev" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.dev.id
  key_name               = aws_key_pair.my_ec2key.key_name
  vpc_security_group_ids = [aws_security_group.dev_sg.id]
  lifecycle {
    ignore_changes = [vpc_security_group_ids]
  }
  root_block_device {
    volume_type = "gp2"
    volume_size = 15
    tags = {
      Name = "main-volume"
    }
  }
  tags = {
    Name = "dev-ec2-demo"
  }
}

resource "aws_ebs_volume" "extra" {
  availability_zone = aws_instance.dev.availability_zone
  size              = 20
  type              = "gp2"
  encrypted         = true
  kms_key_id        = aws_kms_key.ebs_encryption.arn
  tags = {
    Name = "extra-volume"
  }
}

resource "aws_volume_attachment" "extra" {
  device_name  = "/dev/sdf" # OS will typically remap this to /dev/xvdf
  volume_id    = aws_ebs_volume.extra.id
  instance_id  = aws_instance.dev.id
  force_detach = true
}

resource "aws_kms_key" "ebs_encryption" {
  description             = "KMS key for EBS encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "null_resource" "resize_root_volume" {
  depends_on = [aws_instance.dev]

  triggers = {
    instance_id = aws_instance.dev.id
    root_size   = 15
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.my_ec2key.private_key_pem
    host        = aws_instance.dev.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo growpart /dev/xvda 1",
      "sudo resize2fs /dev/xvda1"
    ]
  }
}

resource "null_resource" "mount_and_resize_volume" {
  depends_on = [aws_volume_attachment.extra]

  triggers = {
    volume_id   = aws_ebs_volume.extra.id
    volume_size = aws_ebs_volume.extra.size
    instance_id = aws_instance.dev.id
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.my_ec2key.private_key_pem
    host        = aws_instance.dev.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      # Format only if volume is not yet formatted
      "sudo file -s /dev/xvdf | grep 'data' && sudo mkfs -t ext4 /dev/xvdf || echo 'Already formatted'",

      # Mount volume
      "sudo mkdir -p /mnt/data",
      "sudo mount /dev/xvdf /mnt/data",

      # Persist across reboots
      "grep -q '/mnt/data' /etc/fstab || echo '/dev/xvdf /mnt/data ext4 defaults,nofail 0 2' | sudo tee -a /etc/fstab",

      # Resize filesystem (if needed)
      "sudo resize2fs /dev/xvdf"
    ]
  }
}