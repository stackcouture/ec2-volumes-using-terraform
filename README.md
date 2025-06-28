# EC2 Instance with Encrypted EBS Volume (Terraform)

This Terraform project provisions an EC2 instance with:
- Ubuntu 22.04 AMI
- Custom root volume size
- Encrypted extra EBS volume (auto-mounted)
- Auto-resizing root and data volumes using SSH provisioners

---

## 🔧 Prerequisites

- Terraform CLI (v1.0+)
- AWS CLI configured with valid credentials
- A default VPC/subnet setup (or modify `subnet_id` accordingly)

---

## 🚀 Usage

### 

```bash
1. Initialize
   terraform init

2. Plan
   terraform plan

3. Apply
   terraform apply

After deployment, Terraform will output the public IP of the EC2 instance.

🔑 SSH Access
A new RSA key pair (my-ec2key) is generated automatically.

chmod 400 my-ec2key.pem
ssh -i my-ec2key.pem ubuntu@<EC2_PUBLIC_IP>
Replace <EC2_PUBLIC_IP> with the IP from Terraform outputs.

💽 EBS Volumes
Root volume: Custom size (15 GiB, adjustable via root_block_device.volume_size)

Extra volume: Encrypted, mounted to /mnt/data

Automatically formatted if new

Resize operation is handled via resize2fs

⚠️ Notes
Make sure port 22 is open in your security group.

Don't commit my-ec2key.pem to source control.

Resizing the EBS volume triggers instance-level changes and requires growpart and resize2fs.

🧹 Cleanup
To destroy all resources:

terraform destroy# 

EC2 Instance with Encrypted EBS Volume (Terraform)

This Terraform project provisions an EC2 instance with:
- Ubuntu 22.04 AMI
- Custom root volume size
- Encrypted extra EBS volume (auto-mounted)
- Auto-resizing root and data volumes using SSH provisioners

---

## 📁 Project Structure

.
├── main.tf # Terraform resources and configuration
├── variables.tf # Input variables (not included here)
├── outputs.tf # Output values (e.g., public IP)
├── my-ec2key.pem # Auto-generated SSH private key (ignored in .gitignore)


---

## 🔧 Prerequisites

- Terraform CLI (v1.0+)
- AWS CLI configured with valid credentials
- A default VPC/subnet setup (or modify `subnet_id` accordingly)

---

## 🚀 Usage

    1. Initialize
    terraform init

    2. Plan
    terraform plan
    
    3. Apply
    terraform apply
    After deployment, Terraform will output the public IP of the EC2 instance.

🔑 SSH Access

    A new RSA key pair (my-ec2key) is generated automatically.

    chmod 400 my-ec2key.pem
    ssh -i my-ec2key.pem ubuntu@<EC2_PUBLIC_IP>
    Replace <EC2_PUBLIC_IP> with the IP from Terraform outputs.

💽 EBS Volumes
    Root volume: Custom size (15 GiB, adjustable via root_block_device.volume_size)
    Extra volume: Encrypted, mounted to /mnt/data
    Automatically formatted if new
    Resize operation is handled via resize2fs

⚠️ Notes
    Make sure port 22 is open in your security group.
    Don't commit my-ec2key.pem to source control.

    Resizing the EBS volume triggers instance-level changes and requires growpart and resize2fs.

🧹 Cleanup
    To destroy all resources:
    terraform destroy