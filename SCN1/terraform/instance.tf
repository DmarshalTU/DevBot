# Create 3 instances - one public and two private

# 01. public
resource "aws_instance" "public-01" {
  ami           = var.ami
  instance_type = "t2.micro"
  subnet_id = aws_subnet.sub-public-1a.id                      
  vpc_security_group_ids = [aws_security_group.public-SG.id]    
  key_name = aws_key_pair.public-ec2-public-key.key_name     
  
  # Copy private key of private instances for ansible access. 
  provisioner "file" {
    source      = var.ssh-private-instance["PATH_TO_PRIVATE_KEY"]
    destination = "/home/ubuntu/.ssh/private-instance"
  }

  # Copy ansible's folder for servers configuration.
  provisioner "file" {
    source      = "../ansible"
    destination = "/home/ubuntu/"
  }

  # Copy app's folder for ansible use. 
  provisioner "file" {
    source      = "../app"
    destination = "/home/ubuntu/"
  }

  # Execute commands on public instance.
  provisioner "remote-exec" {
    inline = [
      "chmod 0400 /home/ubuntu/.ssh/private-instance",
      "sudo apt-get update -y",
      "sudo apt-get install ansible -y",
      "touch ~/ansible/inventory",
      "echo '[dev]' > /home/ubuntu/ansible/inventory",
      "echo ${aws_instance.private-01.private_ip} >> /home/ubuntu/ansible/inventory",
      "echo ${aws_instance.private-02.private_ip} >> /home/ubuntu/ansible/inventory",
      "cd ~/ansible",
      "ansible-playbook all-in.yaml",
    ]
  }

  # Connect for remote execute
  connection {
    host        = coalesce(self.public_ip, self.private_ip)
    type        = "ssh"
    user        = var.users["ubuntu"]
    private_key = file(var.ssh-public-instance["PATH_TO_PRIVATE_KEY"])
  }
  
  depends_on = [
    aws_instance.private-01,
    aws_instance.private-02,
    aws_alb_target_group_attachment.instances-attachment-01,
    aws_alb_target_group_attachment.instances-attachment-02,
  ]

  tags = {
    Name = "public-01"
  }   
}

# 02. private
resource "aws_instance" "private-01" {
  ami           = var.ami
  instance_type = "t2.micro"
  subnet_id = aws_subnet.sub-private-1a.id                
  vpc_security_group_ids = [aws_security_group.private-SG.id] 
  key_name = aws_key_pair.private-ec2-public-key.key_name   
  depends_on = [
    aws_nat_gateway.nat-gw,
  ]
  tags = {
    Name = "private-01"
  }   
}

# 03. private
resource "aws_instance" "private-02" {
  ami           = var.ami
  instance_type = "t2.micro"
  subnet_id = aws_subnet.sub-private-1b.id
  vpc_security_group_ids = [aws_security_group.private-SG.id]
  key_name = aws_key_pair.private-ec2-public-key.key_name
  depends_on = [
    aws_nat_gateway.nat-gw,
  ]  
  tags = {
    Name = "private-02"
  }   
}


output "public_ip" {
  value = "${aws_alb.alb.dns_name}"
}