#
# Cookbook Name:: centos_lamp54
# Recipe:: mysql
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

log "mysql recipe"

# Install mysql packages
%w{mysql-server mysql}.each do | pkg |
	yum_package pkg do
		action :install
		options "--enablerepo=remi"
	end


end
