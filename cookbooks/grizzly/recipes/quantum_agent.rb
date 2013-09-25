# Glance variables
role = getRole
controller_role = "controller_node"
quantum_user = "quantum"
private_ip = ""
controller_private_ip = ""
quantum_password = ""
mysql_quantum_password = ""

# Query controller ip
partial_search(:node, 'role:#{controller_role}',
  :keys => {
    'controller_private_ip'   => [ 'grizzly', controller_role, 'network', 'private', 'ip' ],
    'private_ip'  =>  [ 'grizzly', role, 'network', 'private', 'ip' ],
    'quantum_password' => [ 'grizzly', controller_role, quantum_user, 'password' ],
    'mysql_quantum_password' => ['grizzly', controller_role, 'mysql', 'user_data', quantum_user, 'password']
  }
).each do |result|
  controller_private_ip = result['controller_private_ip']
  private_ip = result['private_ip']
  quantum_password = result['quantum_password']
  mysql_quantum_password = result['mysql_quantum_password']
end

package "quantum-plugin-openvswitch-agent quantum-dhcp-agent quantum-l3-agent quantum-metadata-agent" do 
	action :install
end
=begin
bash "Updating quantum.conf" do
  code <<-CODE
   sed -i 's/# verbose = False/verbose = True/g' /etc/quantum/quantum.conf
   sed -i 's/# rabbit_host = localhost/rabbit_host = #{controller_private_ip}/g' /etc/quantum/quantum.conf
   sed -i 's/127.0.0.1/#{controller_private_ip}/g' /etc/quantum/quantum.conf
   sed -i 's/%SERVICE_TENANT_NAME%/service/g' /etc/quantum/quantum.conf
   sed -i 's/%SERVICE_USER%/#{quantum_user}/g' /etc/quantum/quantum.conf
   sed -i 's/%SERVICE_PASSWORD%/#{quantum_password}/g' /etc/quantum/quantum.conf
   sed -i 's/%SERVICE_PASSWORD%/#{quantum_password}/g' /etc/quantum/quantum.conf
   sed -i 's/# use_syslog = False/use_syslog = True/g' /etc/quantum/quantum.conf
   sed -i 's/# syslog_log_facility = LOG_USER/syslog_log_facility=LOG_LOCAL0/g' /etc/quantum/quantum.conf


  CODE
end

bash "Updating ovs_quantum_plugin.ini" do
  code <<-CODE
   sed -i 's:sqlite\\:////var/lib/quantum/ovs.sqlite:mysql\\://#{quantum_user}\\:#{mysql_quantum_password}@#{controller_private_ip}/quantum:g'  /etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini
   sed -i 's/^\\[OVS\\]/\\[OVS\\]\\ntenant_network_type = gre\\ntunnel_id_ranges = 1:1000\\nenable_tunneling = True\\nintegration_bridge = br-int\\ntunnel_bridge = br-tun\\nlocal_ip = #{private_ip}/g' /etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini 
   sed -i 's/# firewall_driver/firewall_driver/g' /etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini
  CODE
end

bash "Updating metadata_agent.ini" do
  code <<-CODE
   sed -i 's/localhost/#{controller_private_ip}/g' /etc/quantum/metadata_agent.ini
   sed -i 's/# nova_metadata_ip = 127.0.0.1/nova_metadata_ip = #{controller_private_ip}/g' /etc/quantum/metadata_agent.ini
   sed -i 's/# nova_metadata_port/nova_metadata_port/g' /etc/quantum/metadata_agent.ini
   sed -i 's/# metadata_proxy_shared_secret =/metadata_proxy_shared_secret = helloOpenStack/g' /etc/quantum/metadata_agent.ini
   sed -i 's/%SERVICE_TENANT_NAME%/service/g' /etc/quantum/metadata_agent.ini
   sed -i 's/%SERVICE_USER%/#{quantum_user}/g' /etc/quantum/metadata_agent.ini
   sed -i 's/%SERVICE_PASSWORD%/#{quantum_password}/g' /etc/quantum/metadata_agent.ini
  CODE
end

bash "Adding quantum into sudoers" do
  not_if("grep quantum /etc/sudoers")
  code <<-CODE
    echo "quantum ALL=NOPASSWD: ALL" >> /etc/sudoers
  CODE
end


%w{quantum-dhcp-agent quantum-l3-agent quantum-metadata-agent quantum-plugin-openvswitch-agent}.each do | service |
  service service do
      action :restart 
  end
end

bash "Addint bridge into /etc/network/interfaces" do
  not_if("grep br-ext /etc/network/interfaces")
  code <<-CODE
    sed -i -r "s/eth0$|eth0 /br-ext /g"  /etc/network/interfaces
    echo -e "auto #{node["grizzly"][role]["network"]["public"]["interface"]}\niface #{node["grizzly"][role]["network"]["public"]["interface"]} inet manual\n\tup ifconfig \\$IFACE 0.0.0.0 up\n\tup ip link set \\$IFACE promisc on\n\tdown ip link set \\$IFACE promisc off\n\tdown ifconfig \\$IFACE down" >> /etc/network/interfaces
    ifconfig #{node["grizzly"][role]["network"]["public"]["interface"]} down && /etc/init.d/networking restart && ovs-vsctl add-port br-ext #{node["grizzly"][role]["network"]["public"]["interface"]}
  CODE
end
=end

