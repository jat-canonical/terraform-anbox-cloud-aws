variable "user_ssh_pub_key" {
  description = "Public SSH key contents for accessing machine."
  type        = string
  nullable    = false
}

variable "user_ssh_priv_key" {
  description = "Private SSH key contents for accessing machine."
  type        = string
  nullable    = false
}

variable "vpc_id" {
  description = "id of the vpc"
  type        = string
  nullable    = false
}

variable "machine_name_prefix" {
  description = "Name of the subcluster environment, used in loadbalancer names."
  type        = string
  nullable    = false
}

variable "subnet" {
  description = "subnet for the instance"
  type        = string
  nullable    = false
}
