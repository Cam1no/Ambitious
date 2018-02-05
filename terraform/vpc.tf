# 参考
# https://www.terraform.io/docs/providers/aws/

# VPC構築
resource "aws_vpc" "vpc-1" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name = "vpc-1"
  }
}

# public subnet構築
resource "aws_subnet" "vpc-1-public-subnet" {
  vpc_id            = "${aws_vpc.vpc-1.id}"
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-1a"

  tags {
    Name = "vpc-1-public-subnet"
  }
}

# private subnet構築
resource "aws_subnet" "vpc-1-private-subnet" {
  vpc_id            = "${aws_vpc.vpc-1.id}"
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-1a"

  tags {
    Name = "vpc-1-private-subnet"
  }
}

# internet gateway構築
resource "aws_internet_gateway" "vpc-1-igw" {
  vpc_id = "${aws_vpc.vpc-1.id}"

  tags {
    Name = "vpc-1-igw"
  }
}

# publicはこのままだと、10.0.0.0/16の宛先のパケットは全て破棄されてしまう
# 0.0.0.0/0の範囲、つまり全ての宛先のパケットは、internet gatewayに転送する
resource "aws_route_table" "vpc-1-public-rt" {
  vpc_id = "${aws_vpc.vpc-1.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.vpc-1-igw.id}"
  }

  tags {
    Name = "vpc-1-public-rt"
  }
}

# 上記で作成したルートテーブルをサブネットに割り当てる
resource "aws_route_table_association" "vpc-1-rta-1" {
  subnet_id      = "${aws_subnet.vpc-1-public-subnet.id}"
  route_table_id = "${aws_route_table.vpc-1-public-rt.id}"
}

# NATの構築
resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.vpc-1-public-subnet.id}"
}

# インターネットからPrivateへの接続は禁止
# Private SubnetからのリクエストはNAT Gatewayで置換してリクエスト
# インターネットからPrivate Subnetに接続する場合は、NAT Gatewayで置換して接続
resource "aws_route_table" "vpc-1-private-rt" {
  vpc_id = "${aws_vpc.vpc-1.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.nat.id}"
  }

  tags {
    Name = "vpc-1-private-rt"
  }
}

resource "aws_route_table_association" "vpc-1-rta-2" {
  subnet_id      = "${aws_subnet.vpc-1-private-subnet.id}"
  route_table_id = "${aws_route_table.vpc-1-private-rt.id}"
}

# web serverのセキュリティーグループ
resource "aws_security_group" "web-sg" {
  name   = "web-sg"
  vpc_id = "${aws_vpc.vpc-1.id}"

  # SSHできるように22番ポート開放
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPリクエストできるように280番ポート開放
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "web-sg"
  }
}

# DB Server用セキュリティーグループ
resource "aws_security_group" "db-sg" {
  name   = "db-sg"
  vpc_id = "${aws_vpc.vpc-1.id}"

  # SSHできるように22番ポート開放
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # MySQLに接続するための3306番ポート開放
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "db-sg"
  }
}
