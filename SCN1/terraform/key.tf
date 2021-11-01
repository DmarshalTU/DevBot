# key for public instance
resource "aws_key_pair" "public-ec2-public-key" {
  key_name   = "public-ec2-public-key"
  public_key = file(var.ssh-public-instance["PATH_TO_PUBLIC_KEY"])
}

# key for private instances
resource "aws_key_pair" "private-ec2-public-key" {
  key_name   = "private-ec2-public-key"
  public_key = file(var.ssh-private-instance["PATH_TO_PUBLIC_KEY"])
}