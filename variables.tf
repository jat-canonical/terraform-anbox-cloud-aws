variable "ua_token" {
  description = "Pro token used for anbox services"
  type        = string
  sensitive   = true
}

variable "constraints" {
  description = "List of constraints that need to be applied to applications. Each constraint must be of format `<constraint_name>=<constraint_value>`"
  type        = list(string)
  default     = []
}

variable "cloud_name" {
  description = "Name of the cloud to deploy the subcluster to"
  type        = string
}

variable "subclusters_per_region" {
  description = "Number of subclusters per region in the given cloud e.g `{ ap-south-east-1 = 1 }`"
  type        = map(list(string))
  nullable    = false
}

variable "lxd_nodes_per_subcluster" {
  description = "Number of lxd nodes to deploy per subcluster"
  type        = number
  default     = 1
}

variable "environment_name" {
  description = "Name of the environment, used to tag all the aws resources."
  type        = string
  nullable    = false
  default     = "anbox-cluster"
}

# The private domain name that will be used by Anbox to address resources within
# the VPC. It must be unique within the account and it must NOT be a publicly
# registered domain name to avoid any conflicts. For more information on private
# route53 zones, see:
# https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/hosted-zones-private.html
variable "private_domain_name" {
  description = "Private domain name used by anbox to address resources within the vpc"
  type        = string
  nullable    = false
  default     = "anbox-cluster.lan"
}

# When you create a VPC, you must specify a range of IPv4 addresses for
# the VPC in the form of a Classless Inter-Domain Routing (CIDR) block;
# for example, 10.0.0.0/16. This is the primary CIDR block for your VPC.
# For more information about CIDR notation, see RFC 4632
variable "vpc_cidr" {
  description = "CIDR for the main VPC"
  type        = string
  nullable    = false
  default     = "10.10.0.0/16"
}

variable "az1" {
  description = "First of 3 AZs to use.  Defaults to the first available in the region."
  type        = string
  nullable    = false
  default     = ""
}

variable "az2" {
  description = "Second of 3 AZs to use.  Defaults to the second available in the region."
  type        = string
  nullable    = false
  default     = ""
}

variable "az3" {
  description = "Third of 3 AZs to use.  Defaults to the third available in the region."
  type        = string
  nullable    = false
  default     = ""
}

# The network ranges to be assigned to the public and private subnets.
# For more information on VPC and subnet sizing, kindly see this AWS documentation:
# https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Subnets.html

variable "public_subnet_1_cidr" {
  description = "CIDR for public subnet in AZ1"
  type        = string
  nullable    = false
  default     = "10.10.1.0/24"
}

variable "private_subnet_1_cidr" {
  description = "CIDR for private subnet in AZ1"
  type        = string
  nullable    = false
  default     = "10.10.11.0/24"
}

variable "controller_addresses" {
    type = list(string)
    description = "List of juju controller addresses"
    nullable = false
}
