# Glance variables
role = getRole
quantum_user = "quantum"
quantum_password = node["grizzly"][role][quantum_user]["password"]
mysql_quantum_password = node["grizzly"][role]["mysql"]["user_data"][quantum_user]["password"]
private_ip = node["grizzly"][role]["network"]["private"]["ip"]
ovs = node["grizzly"][role]['ovs']

package "quantum-server" do 
	action :install
end

template "/etc/quantum/quantum.conf" do
    source "quantum/quantum.conf.erb"
    owner "root"
    group "root"
    mode "0744"
    variables ({ 
      :quantum_user => quantum_user,
      :quantum_password => quantum_password,
      :auth_host => private_ip,
      :rabbit_host => private_ip
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
      :db_ip => private_ip,
      :ovs => ovs
    })
end

service "quantum-server" do
    action :restart 
end
