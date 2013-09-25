# Nova Variables
role = getRole
private_ip = node["grizzly"][role]["network"]["private"]["ip"]
public_ip = node["grizzly"][role]["network"]["public"]["ip"]
nova_user = "nova"
nova_password = node["grizzly"][role][nova_user]["password"]
mysql_nova_password = node["grizzly"][role]["mysql"]["user_data"][nova_user]["password"]
quantum_password = node["grizzly"][role]["quantum"]["password"]

# Installing nova packages
%w{nova-api nova-cert novnc nova-consoleauth nova-scheduler nova-novncproxy nova-doc nova-conductor}.each do |pkg|
	package pkg do
		action :install
	end
end

template "/etc/nova/api-paste.ini" do
  source "nova/api-paste.ini.erb"
  owner "nova"
  group "nova"
  mode "0600"
  variables ({ 
    :auth_host => private_ip,
    :nova_user => nova_user,
    :nova_password => nova_password
  })
end

template "/etc/nova/nova.conf" do
	source "nova/nova.conf.erb"
	owner "nova"
	group "nova"
	mode "0600"
	variables ({ 
    :controller_private_ip => private_ip,
    :controller_public_ip => public_ip,
    :private_ip => private_ip,
    :quantum_password => quantum_password,
    :nova_user => nova_user,
    :nova_password => mysql_nova_password
  })
end

bash "synchronise nova database" do
	code <<-CODE
		nova-manage db sync
	CODE
end 

%w{nova-cert nova-api nova-scheduler nova-consoleauth nova-conductor nova-novncproxy}.each do | service |
	service service do
		action :restart
	end
end
