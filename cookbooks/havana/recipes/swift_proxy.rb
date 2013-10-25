# Controller Variables
controller_private_ip = ""
controller_public_ip = ""
token = ""
swift_hash_path_suffix = ""
swift_password = ""

config = partial_search(:node, 'role:havana_controller_node',
                        :keys => {
                            'private_ip' => ['havana', 'network', 'private', 'ip'],
                            'public_ip' => ['havana', 'network', 'public', 'ip'],
                            'token' => ['havana', 'admin', 'token'],
                            'swift_hash_path_suffix' => ['havana', 'swift', 'swift_hash_path_suffix'],
                            'swift_password' => ['havana', 'swift', 'password']
                        }
).each do |result|
  controller_private_ip = result['private_ip']
  controller_public_ip = result['public_ip']
  token = result['token']
  swift_hash_path_suffix = result['swift_hash_path_suffix']
  swift_password = result['swift_password']
end

log "swift_hash_path_suffix: #{swift_hash_path_suffix}"

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

firewall_rule "rsync" do
  port 873
  source '198.36.126.0/28'
  action :allow
  notifies :enable, "firewall[ufw]"
end

firewall_rule "swift" do
  port 8888
  action :allow
  notifies :enable, "firewall[ufw]"
end

%w{swift swift-proxy memcached python-keystoneclient python-swiftclient python-webob}.each do |pkg|
  package pkg do
    action :install
  end
end

directory "/etc/swift" do
  owner "swift"
  group "swift"
end

bash "Create self signed certificate" do
  code <<-CODE
   cd /etc/swift
   openssl req -new -x509 -nodes -out cert.crt -keyout cert.key -subj '/C=US/ST=a/L=a/CN=#{node["hostname"]}'
  CODE
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

template "/etc/memcached.conf" do
  source "swift/memcached.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables ({
      :ipaddress => node["ipaddress"]
  })
end


template "/etc/swift/proxy-server.conf" do
  source "swift/proxy-server.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables ({
	:keystone_private_ip => controller_public_ip,
	:keystone_admin_token => token,
	:swift_password => swift_password
  })
end


%w{memcached}.each do |service|
  service service do
    action :restart
  end
end

directory "/home/swift/keystone-signing" do
  owner "swift"
  group "swift"
  recursive true
end

bash "Create ring" do
  code <<-CODE
    cd /etc/swift
    echo swift-ring-builder account.builder create 18 3 1 >> /etc/swift/ring-builder
    echo swift-ring-builder container.builder create 18 3 1 >> /etc/swift/ring-builder
    echo swift-ring-builder object.builder create 18 3 1 >> /etc/swift/ring-builder
  CODE
end

devices = %w[ sda2 sdb1 ]
search(:node, "role:havana_swift_storage_node").each do |node|
  devices.each do |device|
    bash "Add devices to ring" do
      code <<-CODE
        echo swift-ring-builder account.builder add z1-#{node["ipaddress"]}:6002/#{device} 100 >> /etc/swift/ring-builder
        echo swift-ring-builder container.builder add z1-#{node["ipaddress"]}:6001/#{device} 100 >> /etc/swift/ring-builder
        echo swift-ring-builder object.builder add z1-#{node["ipaddress"]}:6000/#{device} 100 >> /etc/swift/ring-builder
      CODE
    end
  end
end

bash "Create ring" do
  code <<-CODE
    echo swift-ring-builder account.builder >> /etc/swift/ring-builder
    echo swift-ring-builder container.builder >> /etc/swift/ring-builder
    echo swift-ring-builder object.builder >> /etc/swift/ring-builder
    echo swift-ring-builder account.builder rebalance >> /etc/swift/ring-builder
    echo swift-ring-builder container.builder rebalance >> /etc/swift/ring-builder
    echo swift-ring-builder object.builder rebalance >> /etc/swift/ring-builder
    chown -R swift:swift /etc/swift
  CODE
end


%w{swift-proxy}.each do |service|
  service service do
    action :restart
  end
end





