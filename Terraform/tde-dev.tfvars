###################################################
#--------moduel networking for vpc,subnets,routes,IG,nat-GW------------
aws_region = "ap-south-1"
environment = "dev"
name = "sample"
cidr_block = "10.0.0.0/16"
public_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnets = ["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]
enable_dns_support = "true"
enable_dns_hostnames = "true"
instance_tenancy = "default"
requestor = "mythilibala1985@gmail.com"
customer = "sample"
tenant = "single"
product = "customer1"
manager = "mythilibala1985@gmail.com"
owner = "mythilibala1985@gmail.com"
purpose = "development terraform testing for sample app"

###################################################
#--------moduel for ECS creation------------
ecs_base_ami_name = "amzn2-ami-hvm*"
ecs_instance_type = "t3a.micro"
ecs_volume_size = "30"
ecs_max_size = "1"
ecs_min_size = "1"
ecs_desired_capacity = "1"
