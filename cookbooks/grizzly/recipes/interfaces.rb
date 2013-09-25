#
# Cookbook Name:: grizzly
# Recipe:: interfaces
#
#

# Variables Definitions
role = getRole
controller_role = "controller_node"

# Private network
private_nic = ""
private_ip = "" 
private_netmask = "" 

# Public network
public_nic = "" 
public_ip = "" 
public_netmask = "" 
public_gateway = "" 
public_domain_name = "" 
public_nameserver = "" 

# Query controller 
partial_search(:node, "role:#{controller_role}",
  :keys => {
    'private_nic' =>  ['grizzly', role, 'network', 'private', 'interface' ],
    'private_ip'  =>  ['grizzly', role, 'network', 'private', 'ip' ],
    'private_netmask' =>  ['grizzly', role, 'network', 'private', 'netmask' ],
    'public_nic'  =>  ['grizzly', role, 'network', 'public', 'interface' ],
    'public_ip'  =>  ['grizzly', role, 'network', 'public', 'ip' ],
    'public_netmask'  =>  ['grizzly', role, 'network', 'public', 'netmask' ],
    'public_gateway'  =>  ['grizzly', role, 'network', 'public', 'gateway' ],
    'public_domain_name'  =>  ['grizzly', role, 'network', 'public', 'domain_name' ],
    'public_nameserver'  =>  ['grizzly', role, 'network', 'public', 'nameserver' ]
  }
).each do |result|
  private_nic = result['private_nic']
  private_ip = result['private_ip']
  private_netmask = result['private_netmask'] 
  public_nic = result['public_nic']
  public_ip = result['public_ip']
  public_netmask = result['public_netmask']
  public_gateway = result['public_gateway']
  public_domain_name = result['public_domain_name']
  public_nameserver = result['public_nameserver']
end

template "/etc/network/interfaces" do
  not_if("grep #{private_ip} /etc/network/interfaces && grep #{public_ip} /etc/network/interfaces")
  source "network/interfaces.erb"
  variables ({ 
    :private_interface => private_nic,
    :private_ip => private_ip,
    :private_netmask => private_netmask,
    :public_interface => public_nic,
    :public_ip => public_ip,
    :public_netmask => public_netmask,
    :public_gateway => public_gateway,
    :public_domain_name => public_domain_name,
    :public_nameserver => public_nameserver
  })

end

# Start networking service
service "networking" do
  action :restart
end