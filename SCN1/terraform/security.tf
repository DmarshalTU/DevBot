# 01. public server
resource "aws_security_group" "public-SG" {
  vpc_id      = aws_vpc.main.id
  name        = "public-SG"
  description = "ingress: [ssh] , egress: [all]"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "public-SG"
  }
}

# 02. ALB
resource "aws_security_group" "alb-SG" {
  vpc_id      = aws_vpc.main.id
  name        = "alb-SG"
  description = "ingress: [http,https] , egress: [all]"
  ingress { 
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"] 
      }
  ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "alb-SG"
  }
}

# 03. private servers
resource "aws_security_group" "private-SG" {
  vpc_id      = aws_vpc.main.id
  name        = "private-SG"
  description = "ingress: [ssh,alb-SG] , egress: [all]"
  ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"] 
      } 
  ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        security_groups = [aws_security_group.alb-SG.id]
      }
  ingress {
        from_port   = 0
        to_port     = 0
        protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "private-SG"
  }
}