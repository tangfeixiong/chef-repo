#
# Cookbook Name:: cloudfuse
# Recipe:: default
#
# Copyright 2013, baremetalcloud
#
# All rights reserved - Do Not Redistribute
#

package "build-essential libcurl4-openssl-dev libxml2-dev libssl-dev libfuse-dev" do
	action :install
end

bash "Downloading cloudfuse" do
	code <<-CODE
		mkdir /opt/cloudfuse
		cd /tmp; curl -L -o cloudfuse.tar.gz https://api.github.com/repos/redbo/cloudfuse/tarball
		tar xzf cloudfuse.tar.gz --strip 1 -C /opt/cloudfuse
		cd /opt/cloudfuse && ./configure && make && make install
	CODE
end

file "/root/.cloudfuse" do
	owner "root"
	group "root"
	mode 00700
	action :create
end

bash "Creating initial /root/.cloudfuse file" do
	code <<-CODE
		cat << EOF > /root/.cloudfuse	
		username=
		api_key=
		tenant=
		authurl=http://chain.baremetalcloud.com:5000/v2.0/
		EOF
	CODE
end
