resource "aws_batch_job_definition" "nextstrain_job" {
  # Nextstrain CLI expects the following name:
  name = "nextstrain-job"
  tags = {
    Project = var.project_name
  }
  type = "container"
  platform_capabilities = ["EC2"]

  container_properties = jsonencode({
    image = "nextstrain/base:latest"
    executionRoleArn = aws_iam_role.ecs_task_role.arn
    jobRoleArn = aws_iam_role.ecs_job_role.arn
    memory = var.memory
    vcpus = var.vcpus

/*
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
          "awslogs-group" = aws_cloudwatch_log_group.log_group.name,
          "awslogs-region" = var.aws_region,
          "awslogs-stream-prefix" = "batch"
      }
    }
*/
  })

  retry_strategy {
    attempts = var.retry_attempts
  }

  timeout {
    attempt_duration_seconds = var.timeout_seconds
  }
}

resource "aws_batch_compute_environment" "ec2" {
  compute_environment_name = "${var.project_name}-ec2"

  compute_resources {
    instance_role = aws_iam_instance_profile.ecs_instance_role.arn

    instance_type = [
      "c5.2xlarge",   # 16 GiB,  8 vCPUs, $0.340000 hourly
      "m5.2xlarge",   # 32 GiB,  8 vCPUs, $0.384000 hourly
      "c5.4xlarge"    # 32 GiB, 16 vCPUs, $0.680000 hourly
/* Soon:
      "c6i.2xlarge",   # 16 GiB,  8 vCPUs, $0.340000 hourly
      "m6i.2xlarge",   # 32 GiB,  8 vCPUs, $0.384000 hourly
      "c6i.4xlarge"    # 32 GiB, 16 vCPUs, $0.680000 hourly
 */
    ]

    max_vcpus = 16
    min_vcpus = 0

    security_group_ids = [
      aws_security_group.outbound_only.id,
    ]

    subnets = aws_subnet.subnet.*.id

    type = "EC2"
  }

  service_role = aws_iam_role.batch_service_role.arn
  type         = "MANAGED"
  depends_on   = [aws_iam_role_policy_attachment.batch_service_role]
}

resource "aws_batch_job_queue" "ec2_queue" {
  # Nextstrain CLI expects the following name:
  name     = "nextstrain-job-queue"
  tags = {
    Project = var.project_name
  }
  state    = "ENABLED"
  priority = 1
  compute_environments = [
    aws_batch_compute_environment.ec2.arn
  ]
}