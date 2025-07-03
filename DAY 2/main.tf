provider "aws" {
   region = "ap-south-1"
}

resource "aws_vpc" "vpctf" {
   cidr_block = var.aws_vpc
}

resource "aws_subnet" "pb_subnet1" {
   vpc_id = "
