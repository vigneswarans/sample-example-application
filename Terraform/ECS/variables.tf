variable "ecs_base_ami_name" {
  type        = string
  description = "ecs_base_ami_name"
}
variable "ecs_instance_type" {
  type        = string
  description = "ecs_instance_type"
}
variable "ecs_volume_size" {
  type        = string
  description = "ecs_volume_size"
}
variable "ecs_max_size" {
  type        = string
  description = "ecs_max_size"
}
variable "ecs_min_size" {
  type        = string
  description = "ecs_min_size"
}
variable "ecs_desired_capacity" {
  type        = string
  description = "ecs_desired_capacity"
}
variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "private_subnet" {
  description = "Private subnet ID list to create a subnet attached with NG"
}

variable "private_subnets" {
  description = "Private subnet CIDR list to create a subnet attached with NG"
}

variable "public_subnet" {
  description = "Private subnet ID list to create a subnet attached with NG"
}

variable "public_subnets" {
  description = "Private subnet CIDR list to create a subnet attached with NG"
}

variable "environment" {
  description = "The AWS environment"
  default     = "dev"
}

variable "name" {
  type        = string
  description = "Name of the VPC"
  default     = "ptmaps"
}

variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "us-west-2"
}

variable "requestor" {
  description = "The AWS region to create things in."
  default     = "mythilibala1985@gmail.com"
}

variable "customer" {
  description = "The AWS region to create things in."
  default     = "sample"
}

variable "tenant" {
  description = "The AWS region to create things in."
  default     = "single"
}

variable "product" {
  description = "The AWS region to create things in."
  default     = "customer1"
}

variable "manager" {
  description = "The AWS region to create things in."
  default     = "mythilibala1985@gmail.com"
}

variable "owner" {
  description = "The AWS region to create things in."
  default     = "mythilibala1985@gmail.com"
}

variable "purpose" {
  description = "The AWS region to create things in."
  default     = "development testing for sample app"
}