# Controller Variables
controller_private_ip = ""
controller_public_ip = ""
token = ""
swift_hash_path_suffix = ""

config = partial_search(:node, 'role:controller_node',
                        :keys => {
                            'private_ip' => ['grizzly', 'controller_node', 'network', 'private', 'ip'],
                            'public_ip' => ['grizzly', 'controller_node', 'network', 'public', 'ip'],
                            'token' => ['grizzly', 'controller_node', 'admin', 'token'],
                            'swift_hash_path_suffix' => ['grizzly', 'controller_node', 'swift', 'swift_hash_path_suffix']
                        }
).each do |result|
  controller_private_ip = result['private_ip']
  controller_public_ip = result['public_ip']
  token = result['token']
  swift_hash_path_suffix = result['swift_hash_path_suffix']
end


bash "reset firewall rules" do
  code <<-EOH
    ufw reset
  EOH
end

firewall "ufw" do
  action :enable
end

firewall_rule "ssh" do
  port 22
  protocol :tcp
  action :allow
end

firewall_rule "swift-object" do
  port 6000
  protocol :tcp
  action :allow
end

firewall_rule "swift-container" do
  port 6001
  protocol :tcp
  action :allow
end

firewall_rule "swift-account" do
  port 6002
  protocol :tcp
  action :allow
end


firewall_rule "rsync" do
  port 873
  source '198.36.126.0/28'
  action :allow
  notifies :enable, "firewall[ufw]"
end

%w{swift swift-account swift-container swift-object openssh-server rsync memcached python-netifaces python-xattr python-memcache unzip rpm2cpio xfs xfsprogs}.each do |pkg|
	package pkg do
		action :install
	end
end

directory "/etc/swift" do
  owner "swift"
  group "swift"
end

template "/etc/swift/swift.conf" do
	source "swift/swift.conf.erb"
  owner "swift"
	group "swift"
	mode "0644"
	variables ({
    :swift_hash_path_suffix => swift_hash_path_suffix
  })
end

template "/etc/default/rsync" do
	source "swift/rsync.erb"
  owner "root"
	group "root"
	mode "0644"
end

template "/etc/rsyncd.conf" do
	source "swift/rsyncd.conf.erb"
  owner "swift"
	group "swift"
	mode "0644"
	variables ({
    :ipaddress => node["ipaddress"]
  })
end

template "/etc/swift/megaraid_setup_drives" do
	source "swift/megaraid_setup_drives.erb"
  owner "root"
	group "root"
	mode "0700"
end

directory "/srv/node" do
  owner "swift"
  group "swift"
  recursive true
end

directory "/var/swift/recon" do
  owner "swift"
  group "swift"
  recursive true
end

%w{rsync swift-object swift-object-replicator swift-object-updater swift-object-auditor swift-container swift-container-replicator swift-container-updater swift-container-auditor swift-account swift-account-replicator swift-account-reaper swift-account-auditor}.each do | service |
	service service do
		action :restart
	end
end


