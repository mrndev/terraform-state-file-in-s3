# Example that shows how to keep the terraform state file in a IONOS s3 bucket.
# The script creates a virtual data center with one VM connected to internet.
# See the helloworld example for explanation/comments for the other resource
# definitions (network, server)
#

# In order to access a S3 bucket, you will need the S3 keys from the Data Center
# Designer. Setting the keys in terraform variables (var.xx) and using them in
# the "backend" section (see below) is not allowed. The "S3" backend section
# however does support the AWS_* shell environment variables below. You need to
# export them before running the script.
# export AWS_ACCESS_KEY_ID=5cda83asdfasdfasdfasdf
# export AWS_SECRET_ACCESS_KEY=vMfVHP6Bq3sxHrafasdfasdfasdfasdfasdfasd

terraform {
  required_providers {
    ionoscloud = {
      source = "ionos-cloud/ionoscloud"
      version = "= 6.4.9" 
    }
  }

  backend "s3" {
    bucket                      = "tf-state-bucket-1284"
    key                         = "terraform.tfstate"
    endpoint                    = "https://s3-eu-central-1.ionoscloud.com"
    region                      = "de"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true

    # You could use these as well, but in this example we use the AWS_*
    # environment variables (see above). Writing secrets into the tf scripts is
    # generally bad practice.
    #access_key                  = "xxxx"
    #secret_key                  = "xxxx"
  }
}

# This will create an empty VDC (Virtual Data Center)
resource "ionoscloud_datacenter" "myvdc" {
  name                = "Statefile in S3 example"
  location            = "de/fra"
  description         = "My Virtual Datacenter"
}

# Create the public LAN. Needed to get our VM below to get internet access
resource "ionoscloud_lan" "publan" {
    datacenter_id         = ionoscloud_datacenter.myvdc.id
    public                = true
    name                  = "Public LAN"
}

# Create one server
resource "ionoscloud_server" "myserver" {
    name                  = "My Server"
    datacenter_id         = ionoscloud_datacenter.myvdc.id
    cores                 = 1
    ram                   = 1024
    image_name            = "ubuntu:latest"
    image_password        = "superpswd123"
    type                  = "ENTERPRISE"
    ssh_keys              = ["/home/mnylund/.ssh/id_rsa.pub"]
    volume {
        name              = "OS"
        size              = 50
        disk_type         = "SSD Standard"
    }
    nic {
        lan               = ionoscloud_lan.publan.id
        dhcp              = true
    }
}

# This is just an optional directive to output the above VMs public IP address
# so that you can use it with ssh to connect to the server
output "myserver_ip_address" {
  value = ionoscloud_server.myserver.primary_ip
}


