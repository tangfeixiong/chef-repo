# Recipe:: horizon

%w{memcached libapache2-mod-wsgi openstack-dashboard}.each do |pkg|
	package pkg do
		action :install
	end
end


package "openstack-dashboard-ubuntu-theme" do
  action :purge
end

bash "Enable default apache website" do
  code <<-CODE
    a2ensite default
    a2ensite default-ssl
  CODE
end

%w{apache2 memcached}.each do |srv| 
	service srv do
		action :restart
	end
end
