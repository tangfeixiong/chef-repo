# Glance variables
role = getRole
controller_role = "controller_node"
controller_private_ip = ""
controller_public_ip = ""
private_ip = ""
quantum_user = "quantum"
quantum_password = ""
nova_user = "nova"
nova_password = ""
mysql_nova_password = ""

# Query controller ip
partial_search(:node, "role:#{controller_role}",
  :keys => {
    'controller_private_ip'   => [ 'grizzly', controller_role, 'network', 'private', 'ip' ],
    'controller_public_ip'   => [ 'grizzly', controller_role, 'network', 'public', 'ip' ],
    'private_ip'  =>  [ 'grizzly', role, 'network', 'private', 'ip' ],
    'quantum_password' => [ 'grizzly', controller_role, quantum_user, 'password'],
    'nova_password' => [ 'grizzly', controller_role, nova_user, 'password' ],
    'mysql_nova_password' => ['grizzly', controller_role, 'mysql', 'user_data', nova_user, 'password'],
  }
).each do |result|
  controller_private_ip = result['controller_private_ip']
  controller_public_ip = result['controller_public_ip']
  private_ip = result['private_ip']
  quantum_password = result['quantum_password']
  nova_password = result['nova_password']
  mysql_nova_password = result['mysql_nova_password']
end

%w{nova-compute-kvm sysfsutils}.each do |pkg|
	package pkg do
		action :install
	end
end

template "/etc/nova/api-paste.ini" do
  source "nova/api-paste.ini.erb"
  owner "nova"
  group "nova"
  mode "0600"
  variables ({ 
    :auth_host => private_ip,
    :nova_user => nova_user,
    :nova_password => mysql_nova_password
  })
end


template "/etc/nova/nova-compute.conf" do
  source "nova/nova-compute.conf.erb"
  owner "nova"
  group "nova"
  mode "0600"
end

template "/etc/nova/nova.conf" do
	source "nova/nova.conf.erb"
	owner "nova"
	group "nova"
	mode "0600"
	variables ({ 
	  :controller_private_ip => controller_private_ip,
	  :controller_public_ip => controller_public_ip,
    :private_ip => private_ip,
    :quantum_password => quantum_password,
    :nova_user => nova_user,
    :nova_password => mysql_nova_password
  })
end

# Restart nova-compute
service "nova-compute" do
	action :restart
end
