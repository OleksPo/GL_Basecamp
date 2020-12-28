variable "key_name" {
  description = "Desired name of AWS key pair"
  default = "docker-ubunter.pem"
}

variable "public_key_puth" {
  description = "Desired puth to file of AWS key pair"
  default = "~/.ssh/docker-ubunter.pem"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "eu-central-1"
}

# Ubuntu Precise 16.04 LTS (x64)
variable "aws_amis" {
  type = map
  default = {
    eu-central-1 = "ami-16efb076"
    eu-nord-1 = "ami-a58d0dc5"
    us-east-1 = "ami-f4cc1de2"
    us-west-1 = "ami-fcc19b99"
  }
}
