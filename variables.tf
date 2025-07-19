variable "cidrBlocks" {
  description = "cidr blocks"
  type        = map(any)
  default = {
    internet = "0.0.0.0/0"
  }
}