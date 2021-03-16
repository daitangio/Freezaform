
variable "my_ip" {
  description="Fill in via: terraform apply -var=\"my_ip=$(curl https://checkip.amazonaws.com)\" " 
  // Normally give this value without default to be able to ask for it by terraform
  default=""
}

variable "root_password"{
    description="Pass via -var"
}