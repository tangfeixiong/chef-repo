# Glance variables
role = getRole
neutron_user = "neutron"
neutron_password = node["havana"][role][neutron_user]["password"]
mysql_neutron_password = node["havana"][role]["mysql"]["user_data"][neutron_user]["password"]
private_ip = node["havana"][role]["network"]["private"]["ip"]
ovs = node["havana"][role]['ovs']

package "neutron-server" do 
	action :install
end

template "/etc/neutron/neutron.conf" do
    source "neutron/neutron.conf.erb"
    owner "root"
    group "root"
    mode "0744"
    variables ({ 
      :neutron_user => neutron_user,
      :neutron_password => neutron_password,
      :auth_host => private_ip,
      :rabbit_host => private_ip,
      :mysql_neutron_password => mysql_neutron_password,
      :db_ip => private_ip,
    })
end

template "/etc/neutron/api-paste.ini" do
    source "neutron/api-paste.ini.erb"
    owner "root"
    group "root"
    mode "0744"
    variables ({ 
      :neutron_user => neutron_user,
      :neutron_password => neutron_password,
      :auth_host => private_ip
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
      :db_ip => private_ip,
      :ovs => ovs
    })
end

service "neutron-server" do
    action :restart 
end
