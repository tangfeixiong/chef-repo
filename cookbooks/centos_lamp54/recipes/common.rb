#
# Cookbook Name:: centos_lamp54
# Recipe:: common 
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

log "common recipe"

# Install common packages
node["packages"].each do | pkg | 
	yum_package pkg do
		action :install
	end
end

