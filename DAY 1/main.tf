# First Terraform file to create basic EC2 instance

provider "aws" {
    region = "ap-south-1"
}

resource "aws_instance" "first_resource" {
    ami = "ami-0d03cb826412c6b0f"
    instance_type = "t2.micro"
}
