variable "access_key" {}
variable "secret_key" {}
variable "region" {}
variable "key_name" {}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}
