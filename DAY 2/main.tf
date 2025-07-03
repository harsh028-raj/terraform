provider "aws" {
   region = "ap-south-1"
}

resource "aws_vpc" "myvpc" {
   cidr_block = var.cidr
}

resource "aws_subnet" "pb_subnet1" {
   vpc_id = aws_vpc.myvpc.id
   cidr_block = "10.0.0.0/24"
   availability_zone = "ap-south-1a"
   map_public_ip_on_launch = true
}

resource "aws_subnet" "pb_subnet2" {
   vpc_id = aws_vpc.myvpc.id
   cidr_block = "10.0.0.0/24"
   availability_zone = "ap-south-1b"
   map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw1" {
   vpc_id = aws_vpc.myvpc.id
}

resource "aws_route_table" "rt1" {
   vpc_id = aws_vpc.myvpc.id
}

   route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_internet_gateway.igw1.id
}

resource "aws_route_table_association" "rtsb1" {
    subnet_id = aws_subnet.pb_subnet1
    route_table_id = aws_route_table.rt1.id
}

resource "aws_route_table_association" "rtsb2" {
    subnet_id = aws_subnet.pb_subnet1
    route_table_id = aws_route_table.rt1.id
}

resource "aws_security_group" "sg1" {
   name = "Web"
   vpc_id = aws_vpc.myvpc.id

   tags = {
     Name = "Web"
  }
}

resource "aws_instance" "ec1" {
   ami = "ami-0dcc1e21636832c5d"
   instance_type = "t2micro"
   vpc_security_group_ids = [aws_security_group.Web.id]
   subnet_id = aws_subnet.pb_subnet1.id
   user_data = base64encode(file("userdata.sh"))
}

resource "aws_instance" "ec2" {
   ami = "ami-0dcc1e21636832c5d"
   instance_type = "t2micro"
   vpc_security_group = [aws_security_group.Web.id]
   subnet_id = aws_subnet.pb_subnet2.id
   user_data = base64encode(file("userdata.sh"))
}

resource "aws_lb" "lb1" {
  name = "lb1-1a"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.Web.id]
  subnets = [aws_subnet.sub1.id, aws_subnet.sub2.id]

  tags = {
    Name = Web1"
}
}

 resource "aws_lb_target_group" "albtg" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id
}

 health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "tgatt1" {
  target_group_arn = aws_lb_target_group.albtg.arn
  target_id        = aws_instance.ec1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "tgatt2" {
  target_group_arn = aws_lb_target_group.albtg.arn
  target_id        = aws_instance.ec2.id
  port             = 80
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.lb1.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.albtg.arn
    type             = "forward"
  }
}

output "loadbalancerdns" {
  value = aws_lb.myalb.dns_name
}
