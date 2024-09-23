# Security group for Fargate tasks
resource "aws_security_group" "fargate_sg" {
  name        = "${var.fargate_profile_name}-sg"
  description = "Allow HTTPS and HTTP"
  vpc_id      = aws_vpc.main.id

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
    protocol    = "-1" # allows all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}