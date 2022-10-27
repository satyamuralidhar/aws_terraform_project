variable "location" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "prefix" {
    default = "satya"
}

variable "tagging" {
  type = object({
    env = "string"
    application = "string"
  })
  default = {
    application = "web"
    env = "prod"
  }
  validation {
    condition = length(var.tagging.env) > 3
    error_message = "enviroment name needs to be minimum foure charecters"
  }
}

variable "subnet" {
  type = list
  default = ["10.0.1.0/24 , 10.0.2.0/24"] 
}

variable "env" {
  default = "prod"
}

variable "ami_id" {}

variable "instance_type" {}