include_recipe "havana::neutron_ovs_agent" 

# Glance variables
role = getRole
controller_role = "havana_controller_node"
controller_private_ip = ""
public_interface = ""
private_ip = ""
private_interface = ""
private_netmask = ""
neutron_user = "neutron"
neutron_password = ""
mysql_neutron_password = ""


# Query controller ip
partial_search(:node, "role:#{controller_role}",
  :keys => {
    'controller_private_ip'   => [ 'havana', controller_role, 'network', 'private', 'ip' ],
    'private_ip'  =>  [ 'havana', role, 'network', 'private', 'ip' ],
    'neutron_password' => [ 'havana', controller_role, neutron_user, 'password' ],
    'mysql_neutron_password' => ['havana', controller_role, 'mysql', 'user_data', neutron_user, 'password'],
    'public_interface' => [ 'havana', role, 'network', 'public', 'interface' ],
    'private_interface' => [ 'havana', role, 'network', 'private', 'interface' ],
    'private_netmask' => [ 'havana', role, 'network', 'private', 'netmask' ]
  }
).each do |result|
  controller_private_ip = result['controller_private_ip']
  public_interface = result['public_interface']
  private_ip = result['private_ip']
  private_interface = result['private_interface']
  private_netmask = result['private_netmask']
  neutron_password = result['neutron_password']
  mysql_neutron_password = result['mysql_neutron_password']
end

# neutron-metadata-agent

%w{neutron-dhcp-agent neutron-l3-agent }.each do | pkg |
  package pkg do
      action :install 
  end
end

template "/etc/neutron/metadata_agent.ini" do
    source "neutron/metadata_agent.ini.erb"
    owner "root"
    group "root"
    mode "0744"
    variables ({ 
      :neutron_user => neutron_user,
      :neutron_password => neutron_password,
      :controller_private_ip => controller_private_ip,
      :auth_host => controller_private_ip
    })
end

%w{dhcp_agent l3_agent}.each do | neutron_agents |
  template "/etc/neutron/#{neutron_agents}.ini" do
    source "neutron/#{neutron_agents}.ini.erb"
    owner "root"
    group "root"
    mode "0744"
  end
end


bash "Adding neutron into sudoers" do
  not_if(" grep neutron /etc/sudoers ")
  code <<-CODE
    echo "neutron ALL=NOPASSWD: ALL" >> /etc/sudoers
  CODE
end

%w{neutron-dhcp-agent neutron-l3-agent neutron-metadata-agent neutron-plugin-openvswitch-agent}.each do | service |
  service service do
      action :restart 
  end
end

bash "Adding bridge into /etc/network/interfaces" do
  not_if("grep br-ex /etc/network/interfaces")
  code <<-CODE
    sed -i "s/#{public_interface}/br-ex/g"  /etc/network/interfaces
    echo -e "auto #{public_interface}\niface #{public_interface} inet manual\n\tup ifconfig \\$IFACE 0.0.0.0 up\n\tup ip link set \\$IFACE promisc on\n\tdown ip link set \\$IFACE promisc off\n\tdown ifconfig \\$IFACE down" >> /etc/network/interfaces
    ifconfig #{public_interface} down
    ip addr del #{private_ip}/#{private_netmask} dev #{private_interface}
  CODE
end

bash "Bring bridge br-ex up" do
  not_if("ovs-vsctl list-ports br-ex | grep #{public_interface}")
  code <<-CODE
    ovs-vsctl add-port br-ex #{public_interface}
  CODE
end

service "networking" do
  action :restart 
end
