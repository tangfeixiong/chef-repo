#
# Cookbook Name:: centos_lamp54
# Recipe:: php 
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute

log "php recipe"

# Install php packages
node["php"].each do | pkg |
	yum_package pkg  do
		action :install
		options "--enablerepo=webtatic"
	end
end

script "install ssh2-bet php extension" do
	interpreter "bash"
	user "root"
	code <<-EOH
		echo -e '\n' | pecl install ssh2-beta
		sed -i 's/;   extension=modulename.extension/extension=ssh2.so/g' /etc/php.ini
	EOH
end
