resource "aws_instance" "web-server" {
  ami                    = "${data.aws_ami.amazon_linux.id}"
  instance_type          = "t2.micro"
  key_name               = "${var.key_name}"
  subnet_id              = "${aws_subnet.vpc-1-public-subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.web-sg.id}"]

  associate_public_ip_address = true
  private_ip                  = "10.0.1.10"

  tags {
    Name = "web-server"
  }
}

resource "aws_instance" "db-server" {
  ami                    = "${data.aws_ami.amazon_linux.id}"
  instance_type          = "t2.micro"
  key_name               = "${var.key_name}"
  subnet_id              = "${aws_subnet.vpc-1-private-subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.db-sg.id}"]

  private_ip = "10.0.2.10"

  tags {
    Name = "db-server"
  }
}
