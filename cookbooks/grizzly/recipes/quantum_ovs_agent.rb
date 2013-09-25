# Glance variables
role = getRole
controller_role = "controller_node"
quantum_user = "quantum"
private_ip = ""
controller_private_ip = ""
quantum_password = ""
mysql_quantum_password = ""
ovs = ""

# Query controller ip
partial_search(:node, "role:#{controller_role}",
  :keys => {
    'controller_private_ip'   => [ 'grizzly', controller_role, 'network', 'private', 'ip' ],
    'private_ip'  =>  [ 'grizzly', role, 'network', 'private', 'ip' ],
    'quantum_password' => [ 'grizzly', controller_role, quantum_user, 'password' ],
    'mysql_quantum_password' => ['grizzly', controller_role, 'mysql', 'user_data', quantum_user, 'password'],
    'ovs' => ['grizzly', role, 'ovs']
  }
).each do |result|
  controller_private_ip = result['controller_private_ip']
  private_ip = result['private_ip']
  quantum_password = result['quantum_password']
  mysql_quantum_password = result['mysql_quantum_password']
  ovs = result['ovs']
end

package "quantum-plugin-openvswitch-agent" do 
  action :install
end

template "/etc/quantum/quantum.conf" do
    source "quantum/quantum.conf.erb"
    owner "root"
    group "root"
    mode "0744"
    variables ({
      :rabbit_host => controller_private_ip,
      :quantum_user => quantum_user,
      :quantum_password => quantum_password,
      :auth_host => controller_private_ip
    })
end

template "/etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini" do
    source "quantum/ovs_quantum_plugin.ini.erb"
    owner "root"
    group "root"
    mode "0744"
    variables ({
      :rabbit_host => private_ip,
      :quantum_user => quantum_user,
      :mysql_quantum_password => mysql_quantum_password,
      :db_ip => controller_private_ip,
      :ovs => ovs
    })
end


# Restarting quantum-plugin-openvswitch-agent
service "quantum-plugin-openvswitch-agent" do
    action :restart 
end
