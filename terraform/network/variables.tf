
   
variable "compartment_id" {
    description = "OCI Compartment ID"
    type = string
}

variable "availability_domain" {
    description = "Availability domain for subnets"
    type = string
    default = "xdil:US-SANJOSE-1-AD-1"
}