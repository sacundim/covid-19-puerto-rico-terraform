resource "aws_iam_policy" "access_to_batch" {
  name        = "${var.project_name}-jobs-access-to-batch"
  description = "Grant Nextstrain CLI access to AWS Batch."

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "VisualEditor0",
        "Effect": "Allow",
        "Action": [
          "batch:DescribeJobQueues",
          "batch:TerminateJob",
          "batch:DescribeJobs",
          "batch:ListJobs",
          "batch:CancelJob",
          "batch:SubmitJob",
          "batch:DescribeJobDefinitions",
          "batch:RegisterJobDefinition",
          "batch:TagResource"
        ],
        "Resource": "*"
      },
      {
        "Sid": "VisualEditor1",
        "Effect": "Allow",
        "Action": "iam:PassRole",
        Resource = aws_iam_role.ecs_task_role.arn
      }
    ]
  })
}

resource "aws_iam_policy" "access_to_bucket" {
  name        = "${var.project_name}-jobs-access-to-bucket"
  description = "Grant Nextstrain CLI access to the S3 jobs bucket."

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "VisualEditor0",
        "Effect": "Allow",
        "Action": [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ],
        "Resource": [
          "arn:aws:s3:::${var.jobs_bucket_name}/*",
          "arn:aws:s3:::${var.jobs_bucket_name}"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "read_logs" {
  name        = "${var.project_name}-jobs-access-to-logs"
  description = "Grant Nextstrain CLI access to AWS logging."

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "VisualEditor0",
        "Effect": "Allow",
        "Action": [
          "logs:GetLogEvents",
          "logs:FilterLogEvents",
          "logs:DeleteLogStream"
        ],
        "Resource": [
          "arn:aws:logs:*:*:log-group:/aws/batch/job",
          "arn:aws:logs:*:*:log-group:/aws/batch/job:log-stream:*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "write_logs" {
  name        = "${var.project_name}-jobs-access-to-logs"
  description = "Grant Nextstrain CLI access to AWS logging."

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "VisualEditor0",
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": [
          "arn:aws:logs:*:*:log-group:/aws/batch/job",
          "arn:aws:logs:*:*:log-group:/aws/batch/job:log-stream:*"
        ]
      }
    ]
  })
}


resource "aws_iam_role" "ecs_task_role" {
  name = "${var.project_name}-jobs-role"
  tags = {
    Project = var.project_name
  }

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_read_bucket" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.access_to_bucket.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_write_logs" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.write_logs.arn
}


resource "aws_iam_role" "batch_service_role" {
  name = "${var.project_name}-batch-service-role"
  tags = {
    Project = var.project_name
  }

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
          "Service": "batch.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "batch_service_role" {
  role       = aws_iam_role.batch_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
}

resource "aws_iam_group" "nextstrain_jobs" {
  name = "nextstrain-jobs"
  path = "/"
}

resource "aws_iam_group_policy_attachment" "access_to_batch" {
  group      = aws_iam_group.nextstrain_jobs.name
  policy_arn = aws_iam_policy.access_to_batch.arn
}

resource "aws_iam_group_policy_attachment" "access_to_bucket" {
  group      = aws_iam_group.nextstrain_jobs.name
  policy_arn = aws_iam_policy.access_to_bucket.arn
}

resource "aws_iam_group_policy_attachment" "access_to_logs" {
  group      = aws_iam_group.nextstrain_jobs.name
  policy_arn = aws_iam_policy.read_logs.arn
}

data "aws_iam_user" "user" {
  user_name = var.iam_user
}

resource "aws_iam_user_group_membership" "user_nextstrain_member" {
  user = data.aws_iam_user.user.user_name
  groups = [
    aws_iam_group.nextstrain_jobs.name
  ]
}
