variable "aws_region" { default = "ap-south-1" } 
provider "aws" {
    region = "${var.aws_region}"
    access_key = ""
    secret_key = ""
}

variable "key_name" {default = ""}
data "aws_availability_zones" "all" {}
resource "aws_elb" "elb-test" {
  name = "terraform-asg-example"
  security_groups = ["sg-59d94c30"]
  availability_zones = ["${data.aws_availability_zones.all.names}"]
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:80/"
  }
  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "80"
    instance_protocol = "http"
  }
}
resource "aws_autoscaling_group" "example" {
  launch_configuration = "${aws_launch_configuration.launch1.id}"
  availability_zones = ["${data.aws_availability_zones.all.names}"]
  min_size = 3
  max_size = 3
  load_balancers = ["${aws_elb.elb-test.name}"]
  health_check_type = "ELB"
  tag {
    key = "Name"
    value = "terraform-asg-example"
    propagate_at_launch = true
  }
}
resource "aws_launch_configuration" "launch1" {
  image_id               = "${var.ami}"
  instance_type          = "t2.micro"
  security_groups        = ["sg-0387a96a"]
  key_name               = "${var.key_name}"
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
	      sudo apt-get -y upgrade
	      sudo useradd -s /bin/bash -m k8s-admin
	      (echo "k8s-admin";echo "k8s-admin") | sudo -S passwd k8s-admin
	      sudo usermod -aG sudo k8s-admin
              echo "k8s-admin ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/k8s-admin
              sudo apt-get install \
              apt-transport-https \
              ca-certificates \
              curl \
              software-properties-common -y
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	      sudo add-apt-repository \
              "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
              $(lsb_release -cs) \
              stable"
	      sudo apt-get update
	      sudo apt-get install docker-ce -y
	      sudo usermod -aG docker k8s-admin
              sudo su -c "cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
              deb http://apt.kubernetes.io/ kubernetes-xenial main
              EOF"
              curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
              sudo apt install -y kubectl kubelet kubeadm kubernetes-cni
              EOF
  lifecycle {
    create_before_destroy = true
  }
}
