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
  keep_locally = true
}


// Ensure log dirs exists



# Create stuff like docker_container.webservers["web1"] etc
resource "docker_container" "webservers" {
  for_each= var.web_servers
  image = docker_image.nginx.latest
  name= join("-",  [ local.name_prefix, format("%s",each.key) ])
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
    label="Version"
    value= join(" ", [ local.tf_git_version, local.name_prefix ])
  }



  // Example: set up /etc/nginx/nginx.conf
  // via the upload block
  // the file is uploaded before container start
  upload {
    source=join("/",  [ abspath(path.root), "/etc/nginx.conf"])
    file="/etc/nginx/nginx.conf"
  }

  upload {
    source=join("/",  [ abspath(path.root),"/htdocs/index.html"])
    file="/usr/share/nginx/html/index.html"
  }



}

resource "docker_container" "webservers_via_count" {
  count=1
  image = docker_image.nginx.latest
  name=join("-",  [ local.name_prefix, format("webC-%s",count.index) ] )
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


