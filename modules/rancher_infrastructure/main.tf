resource "exoscale_ssh_keypair" "rancher-ssh-key" {
  name       = "kubernetes-cluster-ssh-key"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

resource "exoscale_affinity" "rancher-nodes" {
  name        = "rancher-nodes"
  description = "Up to 8 rancher nodes are placed on different hypervisors"
  type        = "host anti-affinity"
}

# Create security group for ssh access nodes
resource "exoscale_security_group" "rancher-ssh-access-security-group" {
  name        = "rancher-ssh-access-security-group"
  description = "Security Group for ssh access."
}

# Create security group for rancher nodes
resource "exoscale_security_group" "rancher-nodes-security-group" {
  name        = "rancher-nodes-security-group"
  description = "Security Group to access nodes via web."
}

resource "exoscale_security_group_rule" "rancher-ssh-access-security-group-nodeports" {
  security_group_id = "${exoscale_security_group.rancher-ssh-access-security-group.id}"
  protocol          = "TCP"
  type              = "INGRESS"
  cidr              = "0.0.0.0/0"
  start_port        = 22
  end_port          = 22
}

resource "exoscale_security_group_rule" "rancher-nodes-security-group-https" {
  security_group_id = "${exoscale_security_group.rancher-nodes-security-group.id}"
  protocol          = "TCP"
  type              = "INGRESS"
  cidr              = "0.0.0.0/0"
  start_port        = 443
  end_port          = 443
}

resource "exoscale_security_group_rule" "rancher-nodes-security-group-http" {
  security_group_id = "${exoscale_security_group.rancher-nodes-security-group.id}"
  protocol          = "TCP"
  type              = "INGRESS"
  cidr              = "0.0.0.0/0"
  start_port        = 80
  end_port          = 80
}

# Create 1 Ranchernode (using ubuntu template)
resource "exoscale_compute" "rancher-nodes" {
  display_name    = "rancher-node0${count.index}"
  zone            = "at-vie-1"
  template        = "Linux Ubuntu 18.04 LTS 64-bit"
  size            = "Large"
  disk_size       = 50
  ip6             = false
  key_pair        = "${exoscale_ssh_keypair.rancher-ssh-key.id}"
  security_groups = ["${exoscale_security_group.rancher-ssh-access-security-group.name}", "${exoscale_security_group.rancher-nodes-security-group.name}"]
  affinity_groups = ["${exoscale_affinity.rancher-nodes.name}"]

  state = "Running"

  tags {
    env                = "production"
    kubernetes-cluster = "kubernetes-master"
  }

  count = 1
}

# Template for ansible inventory
data "template_file" "ansible-inventory" {
  template = "${file("ansible-inventory.tpl")}"

  vars {
    rancher_node00_ip = "${exoscale_compute.rancher-nodes.*.ip_address[0]}"
  }
}

# Create inventory file
resource "null_resource" "create-ansible-inventory" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers {
    template = "${data.template_file.ansible-inventory.rendered}"
  }

  provisioner "local-exec" {
    command = "echo \"${data.template_file.ansible-inventory.rendered}\" > inventory"
  }
}
