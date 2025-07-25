variable "cidr_block" {
  default = "10.0.0.0/16"
}

variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "database_subnet_cidrs" {
  type = list(string)
} 

variable "public_subnet_tags" {
  type = map(string)
  default = {}
}

variable "private_subnet_tags" {
  type = map(string)
  default = {}
}

variable "database_subnet_tags" {
  type = map(string)
  default = {}
}

variable "nat_gateway_tags" {
  type = map(string)
  default = {}
}

variable "is_peering_required" {
  default = false
}
