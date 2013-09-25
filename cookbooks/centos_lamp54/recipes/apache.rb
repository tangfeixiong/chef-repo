#
# Cookbook Name:: centos_lamp54
# Recipe:: apache
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# Install httpd package
yum_package "httpd" do
	action :install
        options "--enablerepo=remi"
end

# Start httpd service
service "httpd" do
	action :start
end
