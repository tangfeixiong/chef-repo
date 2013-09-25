# Variables
role = getRole
controller_role = "controller_node"
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
    'floatingip_range'   => [ 'grizzly', role, 'network', 'floating', 'range' ],
    'floatingip_first_ip'  =>  [ 'grizzly', role, 'network', 'floating', 'first_ip' ],
    'floatingip_last_ip'  =>  [ 'grizzly', role, 'network', 'floating', 'last_ip' ],
    'floatingip_gateway'  =>  [ 'grizzly', role, 'network', 'floating', 'gateway' ],
    'controller_private_ip'   => [ 'grizzly', role, 'network', 'private', 'ip' ],
    'controller_public_ip'    => [ 'grizzly', role, 'network', 'public', 'ip' ],
    'network_public_ip'       => [ 'grizzly', 'network_node', 'network', 'public', 'ip' ],
    'compute_public_ip'       => [ 'grizzly', 'compute_node', 'network', 'public', 'ip' ],
    'tenant_name' => ['grizzly', role, 'tenant', 'name'],
    'tenant_username' => ['grizzly', role, 'tenant', 'username'],
    'tenant_password' => ['grizzly', role, 'tenant', 'password'],
    'network_root_password'   => [ 'grizzly', 'network_node', 'root', 'password' ],
    'compute_root_password'   => [ 'grizzly', 'compute_node', 'root', 'password' ]
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


=begin
storage_nodes = partial_search(:node, 'role:grizzly_swift_storage_node',
                        :keys => {
                            'ipaddress' => ['ipaddress'],
                        }
)
proxy_nodes = partial_search(:node, 'role:grizzly_swift_proxy_node',
                        :keys => {
                            'ipaddress' => ['ipaddress'],
                        }
)


template "/root/controller_scripts/distribute_rings" do
  source "controller_scripts/distribute_rings.erb"
  owner "root"
  group "root"
  mode "0700"
  variables({
	:storage_nodes => storage_nodes,
	:proxy_nodes => proxy_nodes
  })
end

=end


#controller_private_ip = ""
#controller_public_ip = ""
#token = ""
#swift_hash_path_suffix = ""
#swift_password = ""

#config = partial_search(:node, 'role:grizzly_controller_node',
#                        :keys => {
#                            'private_ip' => ['grizzly', 'network', 'private', 'ip'],
#                            'public_ip' => ['grizzly', 'network', 'public', 'ip'],
#                            'token' => ['grizzly', 'admin', 'token'],
#                            'swift_hash_path_suffix' => ['grizzly', 'swift', 'swift_hash_path_suffix'],
#                            'swift_password' => ['grizzly', 'swift', 'password']
#                        }
#).each do |result|
#  controller_private_ip = result['private_ip']
#  controller_public_ip = result['public_ip']
#  token = result['token']
#  swift_hash_path_suffix = result['swift_hash_path_suffix']
#  swift_password = result['swift_password']
#end
