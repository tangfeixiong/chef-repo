#
# Author:: Joshua Sierles <joshua@37signals.com>
# Author:: Joshua Timberman <joshua@opscode.com>
# Author:: Nathan Haneysmith <nathan@opscode.com>
# Author:: Seth Chisamore <schisamo@opscode.com>
# Cookbook Name:: nagios
# Recipe:: client
#
# Copyright 2009, 37signals
# Copyright 2009-2011, Opscode, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# determine hosts that NRPE will allow monitoring from
mon_host = ['127.0.0.1']

# put all nagios servers that you find in the NPRE config.

#if node.run_list.roles.include?(node['nagios']['server_role'])
#  mon_host << node['ipaddress']
#elsif node['nagios']['multi_environment_monitoring']
  search(:node, "role:#{node['nagios']['server_role']}") do |n|
    mon_host << n['ipaddress']
  end
#else
#  search(:node, "role:#{node['nagios']['server_role']} AND chef_environment:#{node.chef_environment}") do |n|
#    mon_host << n['ipaddress']
#  end
#end
# on the first run, search isn't available, so if you're the nagios server, go
# ahead and put your own IP address in the NRPE config (unless it's already there).
if node.run_list.roles.include?(node['nagios']['server_role'])
  unless mon_host.include?(node['ipaddress'])
    mon_host << node['ipaddress']
  end
end

mon_host.concat node['nagios']['allowed_hosts'] if node['nagios']['allowed_hosts']

include_recipe "nagios::client_#{node['nagios']['client']['install_method']}"

directory "#{node['nagios']['nrpe']['conf_dir']}/nrpe.d" do
  owner node['nagios']['user']
  group node['nagios']['group']
  mode 00755
end

template "#{node['nagios']['nrpe']['conf_dir']}/nrpe.cfg" do
  source "nrpe.cfg.erb"
  owner node['nagios']['user']
  group node['nagios']['group']
  mode 00644
  variables(
    :mon_host => mon_host,
    :nrpe_directory => "#{node['nagios']['nrpe']['conf_dir']}/nrpe.d"
  )
  notifies :restart, "service[#{node['nagios']['nrpe']['service_name']}]"
end

service node['nagios']['nrpe']['service_name'] do
  action [:start, :enable]
  supports :restart => true, :reload => true, :status => true
end



nagios_nrpecheck "check_processes" do
  command "#{node['nagios']['plugin_dir']}/check_procs"
  action :add
end

nagios_nrpecheck "check_swap" do
  command "#{node['nagios']['plugin_dir']}/check_swap -w 80 -c 50"
  action :add
end

nagios_nrpecheck "check_load" do
  command "#{node['nagios']['plugin_dir']}/check_load  -w 3 -c5"
  action :add
end

nagios_nrpecheck "check_all_disks" do
  command "#{node['nagios']['plugin_dir']}/check_disk -w 20% -c 10%"
  action :add
end

nagios_nrpecheck "check_apache2_process" do
  command "#{node['nagios']['plugin_dir']}/check_procs -C apache2"
  action :add
end

nagios_nrpecheck "check_rabbitmq_process" do
  command "#{node['nagios']['plugin_dir']}/check_procs --ereg-argument-array=rabbitmq"
  action :add
end

nagios_nrpecheck "check_keystone_process" do
  command "#{node['nagios']['plugin_dir']}/check_procs --ereg-argument-array=keystone"
  action :add
end


nagios_nrpecheck "check_cinder-api_process" do
  command "#{node['nagios']['plugin_dir']}/check_procs --ereg-argument-array=cinder-api"
  action :add
end

nagios_nrpecheck "check_cinder-scheduler_process" do
  command "#{node['nagios']['plugin_dir']}/check_procs --ereg-argument-array=cinder-scheduler"
  action :add
end

nagios_nrpecheck "check_cinder-volume_process" do
  command "#{node['nagios']['plugin_dir']}/check_procs --ereg-argument-array=cinder-volume"
  action :add
end

nagios_nrpecheck "check_quantum-dhcp-agent_process" do
  command "#{node['nagios']['plugin_dir']}/check_procs --ereg-argument-array=quantum-dhcp-agent"
  action :add
end

nagios_nrpecheck "check_quantum-l3-agent_process" do
  command "#{node['nagios']['plugin_dir']}/check_procs --ereg-argument-array=quantum-l3-agent"
  action :add
end

nagios_nrpecheck "check_quantum-metadata-agent_process" do
  command "#{node['nagios']['plugin_dir']}/check_procs --ereg-argument-array=quantum-metadata-agent"
  action :add
end

nagios_nrpecheck "check_quantum-openvswitch_process" do
  command "#{node['nagios']['plugin_dir']}/check_procs --ereg-argument-array=quantum-openvswitch-agent"
  action :add
end

nagios_nrpecheck "check_quantum-server_process" do
  command "#{node['nagios']['plugin_dir']}/check_procs --ereg-argument-array=quantum-server"
  action :add
end

nagios_nrpecheck "check_swift-proxy_process" do
  command "#{node['nagios']['plugin_dir']}/check_procs --ereg-argument-array=swift-proxy"
  action :add
end

nagios_nrpecheck "check_confluence_process" do
  command "#{node['nagios']['plugin_dir']}/check_procs --ereg-argument-array=confluence -c 3:3"
  action :add
end
    
nagios_nrpecheck "check_jira_process" do
  command "#{node['nagios']['plugin_dir']}/check_procs --ereg-argument-array=jira -c 2:2"
  action :add
end
nagios_nrpecheck "check_jabber_process" do
  command "#{node['nagios']['plugin_dir']}/check_procs --ereg-argument-array=openfire -c 2:2"
  action :add
end
nagios_nrpecheck "check_mysql" do
   command "#{node['nagios']['plugin_dir']}/check_procs --ereg-argument-array=mysql"
   action :add
end
nagios_nrpecheck "check_kayako_process" do
  command "#{node['nagios']['plugin_dir']}/check_procs --ereg-argument-array=apache2 -c 2:2"
  action :add
end

nagios_nrpecheck "check_nova-api_process" do
	command "#{node['nagios']['plugin_dir']}/check_procs --ereg-argument-array=nova-api -c 4:"
	action :add
end
nagios_nrpecheck "check_nova-cert_process" do
	command "#{node['nagios']['plugin_dir']}/check_procs --ereg-argument-array=nova-cert -c 1:"
	action :add
end
nagios_nrpecheck "check_nova-compute_process" do
	command "#{node['nagios']['plugin_dir']}/check_procs --ereg-argument-array=nova-compute -c 1:"
	action :add
end
nagios_nrpecheck "check_nova-conductor_process" do
	command "#{node['nagios']['plugin_dir']}/check_procs --ereg-argument-array=nova-conductor -c 1:"
	action :add
end
nagios_nrpecheck "check_nova-consoleauth_process" do
	command "#{node['nagios']['plugin_dir']}/check_procs --ereg-argument-array=nova-consoleauth -c 1:"
	action :add
end
nagios_nrpecheck "check_nova-novncproxy_process" do
	command "#{node['nagios']['plugin_dir']}/check_procs --ereg-argument-array=nova-novncproxy -c 1:"
	action :add
end
nagios_nrpecheck "check_nova-scheduler_process" do
	command "#{node['nagios']['plugin_dir']}/check_procs --ereg-argument-array=nova-scheduler -c 1:"
	action :add
end
nagios_nrpecheck "check_openvswitch-switch_process" do
	command "#{node['nagios']['plugin_dir']}/check_procs --ereg-argument-array=quantum-openvswitch-agent -c 1:"
	action :add
end

firewall_rule "nagios_nrpe" do
  port 5666
  protocol :tcp
  action :allow
end

