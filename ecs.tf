resource "aws_ecr_repository" "main" {
  name                 = "todd"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecs_cluster" "main" {
  name = "todds-mod"
}

resource "aws_cloudwatch_log_group" "ecs" {
  name = "todds-mod"
}

resource "aws_ecs_task_definition" "main" {
  container_definitions = jsonencode([
    {
      name      = "todds-mod"
      image     = "557129210947.dkr.ecr.us-east-1.amazonaws.com/todd:todd"
      essential = true
      portMappings = [{
        containerPort = 4000
      }]
      environment = [
      ]
      secrets = [
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group" : "todds-mod",
          "awslogs-region" : "us-east-1",
          "awslogs-stream-prefix" : "todds-mod"
        }
      }
    }
  ])
  network_mode             = "awsvpc"
  family                   = "todds-mod"
  cpu                      = 256
  memory                   = 512
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.fargate_execution.arn
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_ecs_service" "main" {
  name            = "todds-mod"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.public.ids
  }
}
