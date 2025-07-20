resource "aws_instance" "instances" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance-type
  key_name      = var.sshkey
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.sg.id]
  associate_public_ip_address = true


  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"

  
  }


  
  tags = {
    Name = "bastion-host"
  }

  # Ensure the key pair exists before SSH provisioning
  depends_on = [aws_key_pair.key-pair, null_resource.fix_key_permissions]

  connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.sshkey}.pem") # Path to your private key
      host        = self.public_ip
  }

  provisioner "file" {
    source      = "scripts/bootstrap-bastion.sh"
    destination = "/home/ubuntu/bootstrap-bastion.sh"
  }

  provisioner "file" {
    source      = "pod/blueapp.yml"
    destination = "/home/ubuntu/blueapp.yml"
  }

  
  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/bootstrap-bastion.sh",
      "sudo /home/ubuntu/bootstrap-bastion.sh"
    ]

    
  }

  
}

resource "null_resource" "fix_key_permissions" {
  provisioner "local-exec" {
    command = "chmod 400 key.pem"
  }

  # triggers = {
  #   key_file = filemd5("${var.sshkey}.pem")

    
  # }

  # depends_on = [aws_key_pair.key-pair]
  
}
