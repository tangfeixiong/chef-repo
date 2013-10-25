# Variables
role = getRole
controller_role = "havana_controller_node"
floatingip_range = ""
floatingip_first_ip = ""
floatingip_last_ip = ""
floatingip_gateway =  ""
controller_private_ip = ""
controller_public_ip = ""
network_public_ip = ""
compute_public_ip = ""
tenant_name = ""
tenant_username = ""
tenant_password = ""
network_root_password = ""
compute_root_password = ""

# Query floating ip information
partial_search(:node, "role:#{controller_role}",
  :keys => {
    'floatingip_range'   => [ 'havana', role, 'network', 'floating', 'range' ],
    'floatingip_first_ip'  =>  [ 'havana', role, 'network', 'floating', 'first_ip' ],
    'floatingip_last_ip'  =>  [ 'havana', role, 'network', 'floating', 'last_ip' ],
    'floatingip_gateway'  =>  [ 'havana', role, 'network', 'floating', 'gateway' ],
    'controller_private_ip'   => [ 'havana', role, 'network', 'private', 'ip' ],
    'controller_public_ip'    => [ 'havana', role, 'network', 'public', 'ip' ],
    'network_public_ip'       => [ 'havana', 'havana_network_node', 'network', 'public', 'ip' ],
    'compute_public_ip'       => [ 'havana', 'havana_compute_node', 'network', 'public', 'ip' ],
    'tenant_name' => ['havana', role, 'tenant', 'name'],
    'tenant_username' => ['havana', role, 'tenant', 'username'],
    'tenant_password' => ['havana', role, 'tenant', 'password'],
    'network_root_password'   => [ 'havana', 'havana_network_node', 'root', 'password' ],
    'compute_root_password'   => [ 'havana', 'havana_compute_node', 'root', 'password' ]
  }
).each do |result|
  floatingip_range = result['floatingip_range']
  floatingip_first_ip = result['floatingip_first_ip']
  floatingip_last_ip = result['floatingip_last_ip']
  floatingip_gateway = result['floatingip_gateway']
  controller_private_ip = result['controller_private_ip']
  controller_public_ip = result['controller_public_ip']
  network_public_ip = result['network_public_ip']
  compute_public_ip = result['compute_public_ip']
  tenant_name = result['tenant_name']
  tenant_username = result['tenant_username']
  tenant_password = result['tenant_password']
  network_root_password = result['network_root_password']
  compute_root_password = result['compute_root_password']
end

directory "/root/controller_scripts" do
  owner "root"
  group "root"
  mode "0700"
end

package "sshpass" do
  action :install
end

template "/root/controller_scripts/create_tenant" do
  source "controller_scripts/create_tenant.erb"
  owner "root"
  group "root"
  mode "0700"
  variables({
    :floatingip_range => floatingip_range,
    :floatingip_first_ip => floatingip_first_ip,
    :floatingip_last_ip => floatingip_last_ip,
    :floatingip_gateway => floatingip_gateway,
    :controller_private_ip => controller_private_ip,
    :tenant_name => tenant_name,
    :tenant_username => tenant_username,
    :tenant_password => tenant_password
  })
end

template "/root/controller_scripts/setup_hosts_and_keys" do
  source "controller_scripts/setup_hosts_and_keys.erb"
  owner "root"
  group "root"
  mode "0700"
  variables({
    :network_public_ip => network_public_ip,
    :compute_public_ip => compute_public_ip,
    :controller_public_ip => controller_public_ip,
    :network_root_password => network_root_password,
    :compute_root_password => compute_root_password
  })

end
