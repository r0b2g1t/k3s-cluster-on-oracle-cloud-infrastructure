variable "compartment_id" {
  description = "OCI Compartment ID"
  type        = string
}

variable "fingerprint" {
  description = "The fingerprint of the key to use for signing"
  type        = string
}

variable "private_key" {
  description = "Private key to use for signing"
  type        = string
  default = <<EOF
-----BEGIN RSA PRIVATE KEY-----
Proc-Type: 4,ENCRYPTED
DEK-Info: AES-256-CBC,946AD79A9B1AE6C8DBC800C360BF588A

EBoMVop9yknrRYmGxlQJT05PW1bMb5A4lIh4pFfUoo4EynzkHDRbXWdwau+mCNNv
86boFTClAr1AwLi97mT3lxFFOrz+vAQDnnMEeGR4er371pYA/u8mXoN5lj9I+Mqi
SShBzVrtvSvSe86vLSc+Bib8E98L6QbOrEIvr36uIhW6XbC5cJKMQLMDk2pB0X0l
1lH7BcAAUs+VUeyqg8YlirPOcq+fL9w1A/tsTLDKBbz2NEMKx5mHGpphmxDhr+QO
yfY20wQ9vOLsvn2KtmMOp7nxNjwfqrqRCEPoPB1wB63/0tPgqYiKwuoV2NEofPFX
quiqQvFv5P/4v2xP+nESGXe0n3yFh2Zr+sU0ommsr3APUgeGRVAh+ZEyvqip/4DQ
tRcdXNwrAaflRM4XjR0c2vZtLyfsruceLCoPVJNedcPXi3elDB1ztk/lQiEa3XOo
4Rj4Iifo+d8MAmhKXlx4Hly1rrj5yuD2TohfZ076gPbIjOQMTt1ie56BNe7dM10m
kKwLSB8CvRB8868yvS0OB3NAoRiKB7fEXYZEP9GErLYoc1UIw2OMp0QieuDTkOb8
jELMPVOm2cw7uulK32EdyoUpiK63qnh9cfPzVAKN4Qky2DNRI3CixUC4uJHJJCXv
r98Zv4MTyXdcERbj8MbRqiGfe0LUFmdHmPdLNfiMgdmH2rIxdsQ77PIuxrnxNFAi
2QXbOH+74srOW2mFcXEJV7vR8jSfMlsqFV2gHbXKrvLQ2eIDpz/acENW4n3J10yS
KsMlIS9prBfoOe7y8Wh+ufV2iPfXQ8VjyzVx0reGDcJksTXxvQASbCqzvbwXNGwF
N72K8yj80+8JxhhDr/Fw0S7FBbRy8HEbohY4FZB7eFeRj+TaeiI++rl+5MGsSNwS
Ms27vh5ZewqL1MKBmd5+Krws/nqovy2+9t+c4vRLHlZ8j49/fy9C7pKitT6u399w
DQ7qVwNGjD/a05WTBWl7BG01EOu2CjrxTqDW425Dn/SB6RsE87eZgFyFormcuJaU
UGzsRyyj3AP6E2yeEn9rzbX/FAnrM4BTMFW9PiFzSfvFYGVxA2le6iqgLxAZgb77
ypkqfj9jTBlex85JVyPoPyAgTOD+762PjCvbnNyN/nEViVnwl5KZ0Cu5frwLmteb
T9tddNgr1jL49/hcH0iHPp3vHMbdGmUgr0fESNwKtPnElf7hRl2hnmBOhfZnIQX6
/tLIoixZfJ113rK97S0DE77MOv9wCP/thRMX/sssjIxIDg82fSpNVDPxXuDQSB+8
Ct2ueXTj2Zkh/xQ2bc9oY+CwNV4E0mbV1rC60kDEq9ibM9sIaxahEbAa/NdlBJil
w8zizXebPj5MQ+V7FZtlZSqoX0ldEGCPMMBcItwcQGJJJ6QJpdm8iNv+IbPeyD7A
d2zyGIdg1vS3+exn/OCaqxXg90gEciCYO13fikZRrUoFxftNjtXyElIlj4ZWwHav
CVAfyCs0JLIVBC1GIhOFRcsF44k4jbpLKGjYkBodlgERI1cj4XOmDcfndw7hiq1r
bCLi28+BNg6Q+RwvMXbshsh0EHx1FaRCq1tthSfOoPRx/EXWJz9GH+gJogwrVWFn
-----END RSA PRIVATE KEY-----
EOF
}

variable "private_key_password" {
  description = "Password for private key to use for signing"
  type        = string
}

variable "region" {
  description = "The region to connect to. Default: eu-frankfurt-1"
  type        = string
  default     = "eu-frankfurt-1"
}

variable "tenancy_ocid" {
  description = "The tenancy OCID."
  type        = string
}

variable "user_ocid" {
  description = "The user OCID."
  type        = string
}

variable "ssh_authorized_keys" {
  description = "List of authorized SSH keys"
  type        = list(any)
}

locals {
  cidr_blocks = ["10.0.0.0/24"]
  ssh_managemnet_network = "1.1.1.1/32"
}

