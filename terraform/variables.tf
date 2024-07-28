variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

#variable "profile" {
#  description = "AWS Profile Name"
#  default = "ofir_demo_profile"
#}

variable "region" {
  description = "AWS Region Name"
  default = "us-east-1"
}