#
# Cookbook Name:: bind9
# Recipe:: default
#
# Copyright 2011, Mike Adolphs
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

#allocations_item = data_bag("allocations")
#allocations_item.each do |alloc_item| 
#  log "alloc_item.inspect - #{alloc_item.inspect}"
#  blocks = data_bag_item("allocations",alloc_item)
#  log "blocks: #{blocks["blocks"]}"
#end

allocations = Array.new

search(:allocations,"*:*").each do | blocks |
  allocations.push blocks.raw_data["blocks"]
end 

#log "allocations.inspect - #{allocations.inspect}"

template "/etc/bind/named.conf.options" do
  source "named.conf.options.erb"
  owner "root"
  group "root"
  mode 0644
  variables({
    :allocations => allocations
  })
end


package "bind9" do
  action :install
end

template "/etc/bind/named.conf.local" do
  source "named.conf.local.slave.erb"
  owner "root"
  group "root"
  mode 0644
  variables({
    :zonefiles => search(:zones),
    :masters => search(:node, 'role:bind9_master')    
  })
end

service "bind9" do
  pattern "bind9"
  action [:enable, :restart
  ]
end
