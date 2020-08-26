provider "aws" {
    version = "~> 3.0"
    region = "us-east-1"
}

resource "aws_vpc" "lab_test_vpc" {
    cidr_block = "10.11.0.0/16"
    enable_dns_hostnames = true
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
        cidr_blocks = [aws_vpc.lab_test_vpc.cidr_block, "177.41.106.147/32"]
    }

    ingress {
        description = "Allow ssh from my ip"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        #Colocar o seu ip do provedor ou 0.0.0.0/0
        cidr_blocks = ["177.41.106.147/32"]
    }

    ingress {
        description = "Allow nfs from sg"
        from_port = 2049
        to_port = 2049
        protocol = "tcp"
        #Colocar o seu ip do provedor ou 0.0.0.0/0
        cidr_blocks = [aws_vpc.lab_test_vpc.cidr_block]
    }

    ingress {
        description = "Allow db from sg"
        from_port = 5432
        to_port = 5432
        protocol = "tcp"
        #Colocar o seu ip do provedor ou 0.0.0.0/0
        cidr_blocks = [aws_vpc.lab_test_vpc.cidr_block]
    }

    ingress {
        description = "Allow redis from sg"
        from_port = 6379
        to_port = 6379
        protocol = "tcp"
        #Colocar o seu ip do provedor ou 0.0.0.0/0
        cidr_blocks = [aws_vpc.lab_test_vpc.cidr_block]
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


resource "aws_efs_file_system" "lab_test_efs" {
    creation_token = "lab_test_moodle"

  tags = {
    Name = "lab_test_moodle_efs"
  }
  
}

resource "aws_efs_mount_target" "lab_test_efs_mt" {
    file_system_id = aws_efs_file_system.lab_test_efs.id
    subnet_id      = aws_subnet.lab_test_subnet.id
    security_groups = [aws_security_group.lab_test_allow_http.id]
  
}


resource "aws_db_subnet_group" "lab_test_db_subnet" {
    name       = "lab_test_db_subnet"
    subnet_ids = [aws_subnet.lab_test_subnet_private.id, aws_subnet.lab_test_subnet.id]
    
    tags = {
        Name = "lab_test_db_subnet"
        }
    }
    

resource "aws_db_instance" "lab_test_postgresql" {
    identifier           = "moodle"
    allocated_storage    = 20
    storage_type         = "gp2"
    engine               = "postgres"
    port                 = 5432
    engine_version       = "12.3"
    instance_class       = "db.t2.micro"
    skip_final_snapshot  = true
    vpc_security_group_ids  = [aws_security_group.lab_test_allow_http.id]
    name                 = "moodle"
    username             = "moodle"
    password             = "moodle123"
    backup_retention_period = 0
    db_subnet_group_name    = aws_db_subnet_group.lab_test_db_subnet.name
  
}


module "elasticache-moodle-redis" {
    source = "./elasticache"
    cluster_id = "lab-test-moodle"
    node_type = "cache.t3.micro"
    num_cache_nodes = 1
    subnet_ids_security_name = [aws_subnet.lab_test_subnet.id]
    sg_ids = [aws_security_group.lab_test_allow_http.id]
    
    depends = [ "aws_subnet.lab_test_subnet", "aws_security_group.lab_test_allow_http"]
}

data "template_file" "moodle" {
  template = "${file("install_tools.tpl")}"
  
  vars = {
    efs_mount = "${aws_efs_mount_target.lab_test_efs_mt.dns_name}"
  }
}

resource "aws_instance" "poc_terraform" {
    #ami = "ami-02354e95b39ca8dec"
    ami = "ami-0758470213bdd23b1"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.lab_test_allow_http.id]
    key_name = "lab_test_key"
    subnet_id = aws_subnet.lab_test_subnet.id
    #user_data = file("install_nginx.sh")
    user_data = data.template_file.moodle.rendered

    depends_on = [aws_internet_gateway.lab_test_ig, aws_key_pair.lab_test_key, module.elasticache-moodle-redis]
}


resource "aws_instance" "poc_terraform_private" {
    ami = "ami-02354e95b39ca8dec"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.lab_test_allow_http.id]
    key_name = "lab_test_key"
    subnet_id = aws_subnet.lab_test_subnet_private.id
    depends_on = [aws_subnet.lab_test_subnet_private, aws_internet_gateway.lab_test_ig, aws_key_pair.lab_test_key]
}