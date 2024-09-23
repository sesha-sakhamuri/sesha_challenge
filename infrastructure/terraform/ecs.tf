# ECS Cluster
resource "aws_ecs_cluster" "fargate_cluster" {
  name = "${var.fargate_profile_name}-cluster"
}

# IAM Role for ECS task execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = var.role-name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_ecr_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECR Repository for the Docker Image
resource "aws_ecr_repository" "webapp_repo" {
  name                 = "${var.fargate_profile_name}-nginx-image"
  image_tag_mutability = "MUTABLE"
}

# Attach a lifecycle policy to the ECR repository
resource "aws_ecr_lifecycle_policy" "webapp_repo_lifecycle" {
  repository = aws_ecr_repository.webapp_repo.name

  policy = <<POLICY
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Expire untagged images older than 30 days",
      "selection": {
        "tagStatus": "untagged",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": 30
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
POLICY
}

# CloudWatch Log Group for ECS logs
# resource "aws_cloudwatch_log_group" "ecs_nginx_log_group" {
#   name              = "/ecs/nginx"
#   retention_in_days = 3  
# }

# Task Definition
resource "aws_ecs_task_definition" "fargate_task" {
  family                   = "${var.fargate_profile_name}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      "name" : "${var.fargate_profile_name}-container"
      "image" : "${aws_ecr_repository.webapp_repo.repository_url}:latest",
      "cpu" : 256,
      "memory" : 512,
      "essential" : true,
      "portMappings" : [
        {
          "containerPort" : 80,
          "hostPort" : 80
        }
      ],
      # "logConfiguration" : {
      #   "logDriver" : "awslogs",
      #   "options" : {
      #     "awslogs-group" : "/ecs/nginx",
      #     "awslogs-region" : "us-east-2",
      #     "awslogs-stream-prefix" : "nginx"
      #   }
      # }
    }
  ])
}

# ECS Service
resource "aws_ecs_service" "fargate_service" {
  name            = "${var.fargate_profile_name}-service"
  cluster         = aws_ecs_cluster.fargate_cluster.id
  task_definition = aws_ecs_task_definition.fargate_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public.id]
    security_groups  = [aws_security_group.fargate_sg.id]
    assign_public_ip = true
  }

  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_role_policy,
    aws_iam_role_policy_attachment.ecs_task_ecr_policy_attachment
  ]
}
