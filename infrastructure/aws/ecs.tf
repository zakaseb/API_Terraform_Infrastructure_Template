resource "aws_ecs_cluster" "callsign" {
  name = "callsign"
}

resource "aws_ecs_task_definition" "callsign" {
  family = "callsign"
  container_definitions = jsonencode([{
    name      = "callsign"
    image     = "${aws_ecr_repository.callsign.repository_url}:${var.app_version}"
    memory    = 512
    cpu       = 256
    essential = true
    portMappings = [{
      containerPort = var.app_port
      hostPort      = var.app_port
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name
        "awslogs-region"        = var.region
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])

  execution_role_arn       = aws_iam_role.ecs.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "ecs-flask-app-logs"
  retention_in_days = 7 # Set the retention period as needed
}

resource "aws_ecs_service" "callsign" {
  name            = "callsign"
  cluster         = aws_ecs_cluster.callsign.id
  task_definition = aws_ecs_task_definition.callsign.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = module.vpc.private_subnets
    security_groups = [aws_security_group.callsign_ecs.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.callsign.arn
    container_name   = "callsign"
    container_port   = var.app_port
  }

  depends_on = [aws_lb_listener.callsign_http_listener]

  lifecycle {
    ignore_changes = [desired_count]
  }
}

resource "aws_security_group" "callsign_ecs" {
  name   = "callsign-ecs"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_appautoscaling_target" "ecs_service_scaling_target" {
  max_capacity       = 5
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.callsign.name}/${aws_ecs_service.callsign.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_scaling_out_policy" {
  name               = "ecs-service-scaling-out-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_service_scaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_service_scaling_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_service_scaling_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 75.0
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

resource "aws_appautoscaling_policy" "ecs_scaling_in_policy" {
  name               = "ecs-service-scaling-in-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_service_scaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_service_scaling_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_service_scaling_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 30.0
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}
