resource "null_resource" "bastion_setup" {
  depends_on = [aws_instance.bastion]

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install -y git docker.io"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.key.private_key_pem
      host        = aws_eip.bastion_eip.public_ip
    }
  }
}
