include_recipe "grizzly::quantum_ovs_agent" 

# Glance variables
role = getRole
controller_role = "controller_node"
controller_private_ip = ""
public_interface = ""
private_ip = ""
private_interface = ""
private_netmask = ""
quantum_user = "quantum"
quantum_password = ""
mysql_quantum_password = ""


# Query controller ip
partial_search(:node, "role:#{controller_role}",
  :keys => {
    'controller_private_ip'   => [ 'grizzly', controller_role, 'network', 'private', 'ip' ],
    'private_ip'  =>  [ 'grizzly', role, 'network', 'private', 'ip' ],
    'quantum_password' => [ 'grizzly', controller_role, quantum_user, 'password' ],
    'mysql_quantum_password' => ['grizzly', controller_role, 'mysql', 'user_data', quantum_user, 'password'],
    'public_interface' => [ 'grizzly', role, 'network', 'public', 'interface' ],
    'private_interface' => [ 'grizzly', role, 'network', 'private', 'interface' ],
    'private_netmask' => [ 'grizzly', role, 'network', 'private', 'netmask' ]
  }
).each do |result|
  controller_private_ip = result['controller_private_ip']
  public_interface = result['public_interface']
  private_ip = result['private_ip']
  private_interface = result['private_interface']
  private_netmask = result['private_netmask']
  quantum_password = result['quantum_password']
  mysql_quantum_password = result['mysql_quantum_password']
end

%w{quantum-dhcp-agent quantum-l3-agent quantum-metadata-agent}.each do | pkg |
  package pkg do
      action :install 
  end
end

template "/etc/quantum/metadata_agent.ini" do
    source "quantum/metadata_agent.ini.erb"
    owner "root"
    group "root"
    mode "0744"
    variables ({ 
      :quantum_user => quantum_user,
      :quantum_password => quantum_password,
      :controller_private_ip => controller_private_ip,
      :auth_host => controller_private_ip
    })
end

bash "Adding quantum into sudoers" do
  not_if(" grep quantum /etc/sudoers ")
  code <<-CODE
    echo "quantum ALL=NOPASSWD: ALL" >> /etc/sudoers
  CODE
end

%w{quantum-dhcp-agent quantum-l3-agent quantum-metadata-agent quantum-plugin-openvswitch-agent}.each do | service |
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
