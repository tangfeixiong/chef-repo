# Glance variables
role = getRole
controller_role = "havana_controller_node"
quantum_user = "quantum"
private_ip = ""
controller_private_ip = ""
quantum_password = ""
mysql_quantum_password = ""

# Query controller ip
partial_search(:node, 'role:#{controller_role}',
  :keys => {
    'controller_private_ip'   => [ 'havana', controller_role, 'network', 'private', 'ip' ],
    'private_ip'  =>  [ 'havana', role, 'network', 'private', 'ip' ],
    'quantum_password' => [ 'havana', controller_role, quantum_user, 'password' ],
    'mysql_quantum_password' => ['havana', controller_role, 'mysql', 'user_data', quantum_user, 'password']
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