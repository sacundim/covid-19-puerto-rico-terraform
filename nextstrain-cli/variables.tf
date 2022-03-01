variable "project_name" {
  type = string
  description = "The project name, which will be used to construct various resource names."
  default = "covid-19-puerto-rico-nextstrain"
}

variable "main_bucket_name" {
  type = string
  description = "The name of the base S3 bucket to create/use."
  default = "covid-19-puerto-rico-nextstrain"
}

variable "jobs_bucket_name" {
  type = string
  description = "The name of the Nextstrain CLI jobs bucket to create/use."
  default = "covid-19-puerto-rico-nextstrain-jobs"
}

variable "aws_region" {
  description = "The AWS region things are created in."
  default     = "us-west-2"
}

variable "az_count" {
  description = "Number of AZs to cover in a given region. Depends on the AWS region. Most regions have 3."
  default     = "4"
}

variable "cidr_block" {
  description = "Private IP address range to use."
  default = "172.32.132.0/22"
}

variable "iam_user" {
  description = "Username to attach permissions to in IAM."
  default = "covid-19-puerto-rico"
}

variable "vcpus" {
  description = "How many vCPUs to request per Batch task.  With Fargate, the max is 4."
  default = 4
}

variable "memory" {
  description = "How much memory to request per task. With Fargate, the max is 30720."
  default = 12288
}

variable "retry_attempts" {
  description = "How many times to try tasks in AWS Batch."
  default = 1  # Just try once
}

variable "timeout_seconds" {
  description = "Have AWS Batch kill jobs that exceed this many seconds."
  default = 21600  # six hours
}