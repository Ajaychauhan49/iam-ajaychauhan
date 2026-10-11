# Creating VPC
resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr
}

# Creating Subnets
resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "sub2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

#Creating Internet Gateway
resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "myigw"
  }
}

#Creating Route Table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }
}

#Associating Route Table with Subnet
resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.rt.id
}
resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.sub2.id
  route_table_id = aws_route_table.rt.id
}

#security group
resource "aws_security_group" "sg" {
  name        = "sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.myvpc.id

  # ingress means Inbound rules
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  #egress means outbound rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#creating s3

resource "aws_s3_bucket" "mybucket" {
  bucket = "mybucket-8219487586"
}
#enable versioning
resource "aws_s3_bucket_versioning" "mybucket_versioning" {
  bucket = aws_s3_bucket.mybucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# creating ec2 instance

resource "aws_instance" "webserver1" {
  ami                    = "ami-0b6d9d3d33ba97d99"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.sub1.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  user_data              = base64encode(file("userdata.sh"))


  tags = {
    Name = "myec2-1"
  }

}

resource "aws_instance" "webserver2" {
  ami                    = "ami-0b6d9d3d33ba97d99"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.sub2.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  user_data              = base64encode(file("userdata1.sh"))


  tags = {
    Name = "myec2-2"
  }
}

# Load Balancer
resource "aws_lb" "mylb" {
  name               = "mylb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id]
  subnets            = [aws_subnet.sub1.id, aws_subnet.sub2.id]

  tags = {
    name = "WEB"
  }
}

resource "aws_lb_target_group" "tg" {
  name     = "tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id

  health_check {
    path = "/"
    port = "traffic-port"
    #traffic-port means :-> the same port on which your application receives traffic
  }
}

resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.webserver1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.webserver2.id
  port             = 80
}

# Listner

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.mylb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

#Output

output "load_balancer_dns_name" {
  value = aws_lb.mylb.dns_name
}


  