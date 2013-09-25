node.save
=begin
role = getRole
controller_role = "controller_node"

log "Role: #{role}"

# Private network
private_nic = ""
private_ip = "" 
private_netmask = "" 

# Public network
public_nic = "" 
public_ip = "" 
public_netmask = "" 
public_gateway = "" 
public_domain_name = "" 
public_nameserver = "" 

# Query controller 
partial_search(:node, "role:#{controller_role}",
  :keys => {
    'private_nic' =>  ['grizzly', role, 'network', 'private', 'interface' ],
    'private_ip'  =>  ['grizzly', role, 'network', 'private', 'ip' ],
    'private_netmask' =>  ['grizzly', role, 'network', 'private', 'netmask' ],
    'public_nic'  =>  ['grizzly', role, 'network', 'public', 'interface' ],
    'public_ip'  =>  ['grizzly', role, 'network', 'public', 'ip' ],
    'public_netmask'  =>  ['grizzly', role, 'network', 'public', 'netmask' ],
    'public_gateway'  =>  ['grizzly', role, 'network', 'public', 'gateway' ],
    'public_domain_name'  =>  ['grizzly', role, 'network', 'public', 'domain_name' ],
    'public_nameserver'  =>  ['grizzly', role, 'network', 'public', 'nameserver' ]
  }
).each do |result|
  # Private network
  private_nic = result['private_nic']
  private_ip = result['private_ip']
  private_netmask = result['private_netmask'] 
  
  # Public network
  public_nic = result['public_nic']
  public_ip = result['public_ip']
  public_netmask = result['public_netmask']
  public_gateway = result['public_domain_name']
  public_domain_name = result['public_domain_name']
  public_nameserver = result['public_nameserver']
  
  log "private_nic = #{result['private_nic']}"
  log "private_ip = #{result['private_ip']}"
  log "private_netmask = #{result['private_netmask']}" 
  log "public_nic = #{result['public_nic']}"
  log "public_ip = #{result['public_ip']}"
  log "public_netmask = #{result['public_netmask']}"
  log "public_gateway = #{result['public_domain_name']}"
  log "public_domain_name = #{result['public_domain_name']}"
  log "public_nameserver = #{result['public_nameserver']}"
  
end

log "ovs = #{node['grizzly'][controller_role]['ovs']}"

template "/opt/foo.conf" do
    source "foo.conf.erb"
    owner "root"
    group "root"
    mode "0744"
    variables ({
      :ovs => node['grizzly'][controller_role]['ovs']
    })
end

=begin
ovs = {
  "properties" => [
    "tenant_network_type", "tunnel_id_ranges", "integration_bridge", "tunnel_bridge",  "local_ip", "enable_tunneling"
  ],
  "tenant_network_type" => "gre",
  "tunnel_id_ranges" => "1:1000",
  "integration_bridge" => "br-int",
  "tunnel_bridge" => "br-tun",
  "local_ip" => "10.20.20.52",
  "enable_tunneling" => "True"
}

template "/opt/foo.conf" do
    source "foo.conf.erb"
    owner "root"
    group "root"
    mode "0744"
    variables ({
      :ovs => ovs
    })
end
=end
