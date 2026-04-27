variable "instance_type" {
  description = "EC2 Instance Type for Bastion"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Key Name for SSH access"
  type        = string
  default     = "devops-key"
}

variable "my_ip" {
  description = "Your Public IP for SSH access to Bastion"
  type        = string
}
