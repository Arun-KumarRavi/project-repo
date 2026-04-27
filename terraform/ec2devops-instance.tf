resource "aws_instance" "devops_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.devops_instance_type
  subnet_id     = module.vpc.private_subnets[0]
  key_name      = aws_key_pair.generated_key.key_name

  vpc_security_group_ids = [aws_security_group.devops_sg.id]

  root_block_device {
    volume_size = var.devops_volume_size
    volume_type = "gp3"
  }

 user_data = <<-EOF
#!/bin/bash
set -e  # stop if any command fails

echo "STARTING SETUP..."

# -------------------------
# Update system
# -------------------------
apt update -y
apt upgrade -y

# -------------------------
# Basic tools
# -------------------------
apt install -y fontconfig openjdk-21-jre unzip curl wget gnupg lsb-release software-properties-common

# -------------------------
# Install Docker
# -------------------------
apt install -y docker.io
systemctl enable docker
systemctl start docker

# wait for docker
sleep 10

# -------------------------
# Install Jenkins
# -------------------------
mkdir -p /etc/apt/keyrings

wget -O /etc/apt/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" > /etc/apt/sources.list.d/jenkins.list

apt update -y
apt install -y jenkins

systemctl enable jenkins
systemctl start jenkins

# wait Jenkins
sleep 15

# -------------------------
# Add Jenkins to Docker
# -------------------------
usermod -aG docker jenkins
systemctl restart jenkins

# -------------------------
# Docker Compose
# -------------------------
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# -------------------------
# Git
# -------------------------
apt install -y git

# -------------------------
# Node.js
# -------------------------
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

# -------------------------
# Python
# -------------------------
apt install -y python3 python3-pip python3-venv

# -------------------------
# Trivy
# -------------------------
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | tee /usr/share/keyrings/trivy.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" >> /etc/apt/sources.list.d/trivy.list

apt update -y
apt install -y trivy

# -------------------------
# kubectl
# -------------------------
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" > /etc/apt/sources.list.d/kubernetes.list

apt update -y
apt install -y kubectl

# -------------------------
# AWS CLI
# -------------------------
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# -------------------------
# eksctl
# -------------------------
curl --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz" | tar xz -C /tmp
mv /tmp/eksctl /usr/local/bin

# -------------------------
# Helm
# -------------------------
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# -------------------------
# SonarQube (after Docker ready)
# -------------------------
sleep 10
docker run -d --name sonarqube -p 9000:9000 sonarqube:lts-community

echo "SETUP COMPLETED"

EOF