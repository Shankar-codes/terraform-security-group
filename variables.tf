variable "project_name" {
  type        = string
}

variable "environment" {
  type        = string
}

variable "sg_name" {
  type        = string
}

variable "sg_description" {
  default     = ""
}

variable "aws_vpc.main.id" {
  type        = string
}


variable "sg_tags" {
  type        = map
  default     = {}
}
