# Glance variables
role = getRole
controller_role = "havana_controller_node"
neutron_user = "neutron"
private_ip = ""
controller_private_ip = ""
neutron_password = ""
mysql_neutron_password = ""
ovs = ""

# Query controller ip
partial_search(:node, "role:#{controller_role}",
  :keys => {
    'controller_private_ip'   => [ 'havana', controller_role, 'network', 'private', 'ip' ],
    'private_ip'  =>  [ 'havana', role, 'network', 'private', 'ip' ],
    'neutron_password' => [ 'havana', controller_role, neutron_user, 'password' ],
    'mysql_neutron_password' => ['havana', controller_role, 'mysql', 'user_data', neutron_user, 'password'],
    'ovs' => ['havana', role, 'ovs']
  }
).each do |result|
  controller_private_ip = result['controller_private_ip']
  private_ip = result['private_ip']
  neutron_password = result['neutron_password']
  mysql_neutron_password = result['mysql_neutron_password']
  ovs = result['ovs']
end

package "neutron-plugin-openvswitch-agent" do 
  action :install
end

template "/etc/neutron/neutron.conf" do
    source "neutron/neutron.conf.erb"
    owner "root"
    group "root"
    mode "0744"
    variables ({
      :rabbit_host => controller_private_ip,
      :neutron_user => neutron_user,
      :neutron_password => neutron_password,
      :auth_host => controller_private_ip,
      :db_ip => controller_private_ip,
      :mysql_neutron_password => mysql_neutron_password
    })
end

template "/etc/neutron/plugins/openvswitch/ovs_neutron_plugin.ini" do
    source "neutron/ovs_neutron_plugin.ini.erb"
    owner "root"
    group "root"
    mode "0744"
    variables ({
      :rabbit_host => private_ip,
      :neutron_user => neutron_user,
      :mysql_neutron_password => mysql_neutron_password,
      :db_ip => controller_private_ip,
      :ovs => ovs
    })
end


# Restarting neutron-plugin-openvswitch-agent
service "neutron-plugin-openvswitch-agent" do
    action :restart 
end
