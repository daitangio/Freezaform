variable "mantainer" {
  default="Giovanni Giorgi"
}

variable "web_servers" {
  // type = list(map(string))
  default = {
     web1=8001
     web2=8002
  }  
}
resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = false
}


// Ensure log dirs exists



# Create stuff like docker_container.webservers["web1"] etc
resource "docker_container" "webservers" {
  for_each= var.web_servers
  image = docker_image.nginx.latest
  name=format("%s",each.key)
  ports {
    external= each.value
    internal=80
  }
  must_run= true
  # Memory limit Mbs
  memory=64
  #The total memory limit (memory + swap) for the container in MBs. 
  # Bug? It seems apply set to -1
  memory_swap=-1

  labels {
    label="Terraform_Mantainer"
    value=var.mantainer
  }



  // Example: set up /etc/nginx/nginx.conf
  // via the upload block
  // the file is uploaded before container start
  upload {
    source=join("/",  [ abspath(path.root), "/etc/nginx.conf"])
    file="/etc/nginx/nginx.conf"
  }


/*
  // Consolidate logging
  // /var/log/nginx/
  mounts {
    source=join("/",  [ abspath(path.root), "logs",each.key])
    type="bind"
    target="/var/log/nginx"
    read_only=false
  }  
*/

}

resource "docker_container" "webservers_via_count" {
  count=1
  image = docker_image.nginx.latest
  name=format("webC-%s",count.index)
  ports {
    external= (8100+count.index+1)
    internal=80
  }
}

# For functions see https://www.terraform.io/docs/configuration/functions.html
# NB: first argument is a map, the second is a list, so we must do some magic
output "web_servers_public_ports" {
  value = [for r in concat(values(docker_container.webservers), docker_container.webservers_via_count): format("%s -> %s ",r.name , r.ports[0].external) ]
}


