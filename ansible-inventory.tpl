[default]

[rancher_nodes]
${rancher_node00_ip}

[rancher_nodes:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/id_rsa
ansible_python_interpreter=/usr/bin/python3

