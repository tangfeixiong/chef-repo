#!/bin/bash

cd /etc/chef-server/chef-repo/
# Upload cookbooks, environment files, roles and data bags
knife cookbook upload -o /etc/chef-server/chef-repo/cookbooks --all
knife environment from file /etc/chef-server/chef-repo/environments/*.json
knife role from file /etc/chef-server/chef-repo/roles/*.rb
knife data bag create nagios_contacts
knife data bag create nagios_services
knife data bag create nagios_unmanagedhosts
knife data bag create users
knife data bag from file -a

# Update controller's environment
EDITOR="sed -e \"s/_default/controller_node_env/\" -i " knife node edit controller

# Associate OpenStack roles into  controller node
knife node run_list add controller 'role[firewall], role[controller_node]'

# 60 seconds is the required time so the new environment will be available when chef-client runs
sleep 60 && chef-client

# Setup hosts file and share ssh contronller public key across network and compute nodes
/root/controller_scripts/setup_hosts_and_keys

# Bootstrap network and compute node
knife bootstrap -N network network  -i /root/.ssh/id_rsa
knife bootstrap -N compute-001 compute-001 -i /root/.ssh/id_rsa

# Associate OpenStack roles into network and compute nodes
knife node run_list add network 'role[firewall], role[network_node]'
knife node run_list add compute-001 'role[firewall], role[compute_node]'

# Run chef-client on network and compute node
ssh network chef-client
ssh compute-001 chef-client

# Creates an initial tenant and network to the user
/root/controller_scripts/create_tenant

# Associate Monitoring roles into all nodes and execute chef-client 
knife node run_list add controller 'role[monitoring_server], role[monitoring_client]'
chef-client
knife node run_list add network 'role[monitoring_client]'
ssh network chef-client
knife node run_list add compute-001 'role[monitoring_client]'
ssh compute-001 chef-client

