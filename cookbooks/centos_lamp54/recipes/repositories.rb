#
# Cookbook Name:: centos_lamp54
# Recipe:: repositories 
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

log "repositories recipe"

node["rpm"].each do | pkg |
	# Download repository rpm
	remote_file "/tmp/#{pkg.split(/\//).last}" do 
		source pkg 
	end
	
	# Install rpm
	rpm_package pkg.split(/\//).last do
		action :install
		source "/tmp/#{pkg.split(/\//).last}"
	end
	
end
