// Set up rules for module.aurora.this_security_group_id
locals {
  service_list={
    ssh_port  = 22,
    http_port = 80,    
    postgresql= 5432
  } 

}


resource aws_security_group_rule personal_ip1 {
  for_each = local.service_list 
  type      = "ingress"
  from_port = each.value
  to_port   = each.value
  protocol  = "tcp"
  # Current bastion internal ip
  # Fix a single IP
  cidr_blocks = [
    join("/",[var.my_ip, "32"])
  ]
  security_group_id = module.aurora.this_security_group_id
  description       = join("", ["Single IP ", each.key, "(", format("%s", each.value), ")", " comunication"])
}