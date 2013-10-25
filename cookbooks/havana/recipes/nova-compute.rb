# Glance variables
role = getRole
controller_role = "havana_controller_node"
controller_private_ip = ""
controller_public_ip = ""
private_ip = ""
neutron_user = "neutron"
neutron_password = ""
nova_user = "nova"
nova_password = ""
mysql_nova_password = ""

# Query controller ip
partial_search(:node, "role:#{controller_role}",
  :keys => {
    'controller_private_ip'   => [ 'havana', controller_role, 'network', 'private', 'ip' ],
    'controller_public_ip'   => [ 'havana', controller_role, 'network', 'public', 'ip' ],
    'private_ip'  =>  [ 'havana', role, 'network', 'private', 'ip' ],
    'neutron_password' => [ 'havana', controller_role, neutron_user, 'password'],
    'nova_password' => [ 'havana', controller_role, nova_user, 'password' ],
    'mysql_nova_password' => ['havana', controller_role, 'mysql', 'user_data', nova_user, 'password'],
  }
).each do |result|
  controller_private_ip = result['controller_private_ip']
  controller_public_ip = result['controller_public_ip']
  private_ip = result['private_ip']
  neutron_password = result['neutron_password']
  nova_password = result['nova_password']
  mysql_nova_password = result['mysql_nova_password']
end


bash "Create or update supermin appliance" do
  code <<-CODE
    echo "libguestfs0     libguestfs/update-appliance     boolean true" | debconf-set-selections
  CODE
end


%w{nova-compute-kvm python-novaclient python-guestfs sysfsutils}.each do |pkg|
	package pkg do
		action :install
	end
end

# Make kernel readable by non-root users
bash "kernel readable by non-root users" do
  code <<-CODE
    chmod 0644 /boot/vmlinuz*
  CODE
end

# Remove SQlite Database
bash "Remove SQlite database" do
  not_if do ::File.exists?('/var/lib/nova/nova.sqlite') end
  code <<-CODE
    rm /var/lib/nova/nova.sqlite
  CODE
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
    :neutron_password => neutron_password,
    :nova_user => nova_user,
    :nova_password => mysql_nova_password
  })
end


# Restart nova-compute
service "nova-compute" do
	action :restart
end
