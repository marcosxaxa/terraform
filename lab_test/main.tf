provider "aws" {
    version = "~> 3.0"
    region = "us-east-1"
}

resource "aws_vpc" "lab_test_vpc" {
    cidr_block = "10.11.0.0/16"
    tags = {
        Name = "lab_test_vpc"
    }

}

resource "aws_subnet" "lab_test_subnet" {
    vpc_id = aws_vpc.lab_test_vpc.id
    cidr_block = "10.11.29.0/24"
    map_public_ip_on_launch = true
    tags = {
        Name = "lab_test_subnet"
    }
    depends_on = [
        aws_vpc.lab_test_vpc
    ]

}

resource "aws_subnet" "lab_test_subnet_private" {
    vpc_id = aws_vpc.lab_test_vpc.id
    cidr_block = "10.11.25.0/24"
    tags = {
        Name = "lab_test_subnet_private"
    }
    depends_on = [aws_vpc.lab_test_vpc]
}

resource "aws_internet_gateway" "lab_test_ig" {
    vpc_id = aws_vpc.lab_test_vpc.id

    tags = {
        Name = "lab_test_ig"
    }
}

resource "aws_key_pair" "lab_test_key" {
    key_name = "lab_test_key"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDfQVJpgnqzRpMZoKlS1P/g/tYEVlgev1tSLY7QbjIc6dtB+ceMOfzejQWkaLXNDoj+g+4dzgFlebJKD+sNw2EjoyWCK0hogyvTvptWWEd5dJr6wwFI4dbZM1x08+9vOt0OVmMkTvVBOH/VUyUR3WyRohjMzQ8FqhBSPnf2Wr1hfIhlNHvfvdZJtkvfKoIj5NkyiQcw6ah/F7uxhoAPAryekTYhR/8qQgA9ATIRa0tRdbaXyMNJLX2bNT+ZYIJBZJSJ7gr0BVzioN27gSKw22LdudLgiI0jMes7JHPeVwHUcr9FmDMuAtc9secLI9dqZ8B5poYhT4c2rWzSF8ODR8dLg3REhIhWW4K25vPk2WHfEOvSgwiB8kX3nc2D4gi3hr+xTcqmBriPyiBGkdFpqEpgF+Jo4uS+OnIC4RC/tM3q4UGKGOY/bd+F5kkB9pzsySLxEL98mWAe1YiPivZ7mG0m1U0/o3D29YIB6upocgmkxwUZc4BS8oQdyyuhak4YtAs= marcos@marcos-laptop"
}

resource "aws_route_table" "lab_test_rt" {
    vpc_id = aws_vpc.lab_test_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.lab_test_ig.id
    }
    tags = {
        Name = "lab_test"
    }

    depends_on = [aws_internet_gateway.lab_test_ig]
}


resource "aws_route_table_association" "lab_test_rt_a" {
    subnet_id = aws_subnet.lab_test_subnet.id
    route_table_id = aws_route_table.lab_test_rt.id
    depends_on = [aws_route_table.lab_test_rt]
}

resource "aws_security_group" "lab_test_allow_http" {
    name = "allow_http"
    description = "Allow http access"
    vpc_id = aws_vpc.lab_test_vpc.id

    ingress {
        description = "HTTP from VPC"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        #Colocar o seu ip do provedor ou 0.0.0.0/0
        cidr_blocks = [aws_vpc.lab_test_vpc.cidr_block, "177.43.23.205/32"]
    }

    ingress {
        description = "Allow ssh from my ip"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        #Colocar o seu ip do provedor ou 0.0.0.0/0
        cidr_blocks = ["177.43.23.205/32"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "allow_http_pod_lab_test"
    }
}


resource "aws_instance" "poc_terraform" {
    ami = "ami-02354e95b39ca8dec"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.lab_test_allow_http.id]
    key_name = "lab_test_key"
    subnet_id = aws_subnet.lab_test_subnet.id
    user_data = file("install_nginx.sh")

    depends_on = [aws_internet_gateway.lab_test_ig, aws_key_pair.lab_test_key]
}


resource "aws_instance" "poc_terraform_private" {
    ami = "ami-02354e95b39ca8dec"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.lab_test_allow_http.id]
    key_name = "lab_test_key"
    subnet_id = aws_subnet.lab_test_subnet_private.id
    depends_on = [aws_subnet.lab_test_subnet_private, aws_internet_gateway.lab_test_ig, aws_key_pair.lab_test_key]
}