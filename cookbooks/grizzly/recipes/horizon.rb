%w{openstack-dashboard memcached}.each do |pkg|
	package pkg do
		action :install
	end
end

package "openstack-dashboard-ubuntu-theme" do
  action :purge
end

%w{apache2 memcached}.each do |srv| 
	service srv do
		action :restart
	end
end
