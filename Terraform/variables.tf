###################################################

#--------moduel networking for vpc,subnets,routes,IG,nat-GW------------
variable "name" {
  type        = string
  description = "Name of the VPC"
  default     = "sample"
}

variable "environment" {
  type        = string
  description = "Name of the env"
  default     = "dev"
}

variable "cidr_block" {
  description = "VPC CIDR range"
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "Public subnet CIDR list to create a subnet attached with IG"
  type    = list
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnets" {
  description = "Private subnet CIDR list to create a subnet attached with NG"
  type    = list
  default = ["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]
}

data "aws_availability_zones" "available" {
  state = "available"
}

variable "enable_dns_support" {
  description = "A boolean flag to enable/disable DNS support in the VPC. Defaults to true."
  type    = bool
  default = true
}

variable "enable_dns_hostnames" {
  description = "A boolean flag to enable/disable DNS hostnames in the VPC"
  type    = bool
  default = true
}

variable "instance_tenancy" {
  description = "Tenancy of instances spin up within VPC"
  type    = string
  default = "default"
}

variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "ap-south-1"
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

###################################################
#--------moduel for ECS creation------------
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
