%w{openvswitch-switch openvswitch-datapath-dkms}.each do |pkg|
	package pkg do
		action :install
	end
end

service "openvswitch-switch" do
  action :restart
end


bash "create integration bridge" do
 not_if("ovs-vsctl list-br | grep br-int")
 code <<-CODE
  ovs-vsctl add-br br-int
 CODE
end


bash "create external bridge" do
 not_if { node["roles"].include?('compute_node') } 
 not_if("ovs-vsctl list-br | grep br-ex")
 code <<-CODE
  ovs-vsctl add-br br-ex
 CODE
end

service "openvswitch-switch" do
  action :restart
end

