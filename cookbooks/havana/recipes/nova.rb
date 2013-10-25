# Nova Variables
role = getRole
private_ip = node["havana"][role]["network"]["private"]["ip"]
public_ip = node["havana"][role]["network"]["public"]["ip"]
nova_user = "nova"
nova_password = node["havana"][role][nova_user]["password"]
mysql_nova_password = node["havana"][role]["mysql"]["user_data"][nova_user]["password"]
neutron_password = node["havana"][role]["neutron"]["password"]

# Installing nova packages
%w{nova-novncproxy novnc nova-api nova-ajax-console-proxy nova-cert nova-conductor nova-consoleauth nova-doc nova-scheduler python-novaclient}.each do |pkg|
	package pkg do
		action :install
	end
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
    :neutron_password => neutron_password,
    :nova_user => nova_user,
    :nova_password => mysql_nova_password
  })
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


bash "synchronise nova database" do
	code <<-CODE
		nova-manage db sync
	CODE
end 

%w{nova-api nova-cert nova-consoleauth nova-scheduler nova-conductor nova-novncproxy}.each do | service |
	service service do
		action :restart
	end
end
