# ----------------------------------------------------------------------------------
# output terraform resources
# ------------------------------------------------------------------------------------------
output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet" {
  value = aws_subnet.public-subnet
}

output "private_subnet" {
  value = aws_subnet.private-subnet
}
