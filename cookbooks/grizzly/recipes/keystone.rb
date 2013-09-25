# Keystone variables
role = getRole
admin_token = node["grizzly"][role]["admin"]["token"]
admin_email = node["grizzly"][role]["admin"]["email"]
admin_password = node["grizzly"][role]["admin"]["password"]
private_ip = node["grizzly"][role]["network"]["private"]["ip"]
public_ip = node["grizzly"][role]["network"]["public"]["ip"]
nova_password = node["grizzly"][role]["nova"]["password"]
glance_password = node["grizzly"][role]["glance"]["password"]
quantum_password = node["grizzly"][role]["quantum"]["password"]
cinder_password = node["grizzly"][role]["cinder"]["password"]
swift_password = node["grizzly"][role]["swift"]["password"]
swift_proxy_ip = node["grizzly"][role]["swift"]["swift_proxy_ip"]

# Keystone credentials
keystone_user = "keystone"
keystone_password = node["grizzly"][role]["mysql"]["user_data"][keystone_user]["password"]
db_ip = node["grizzly"][role]["network"]["private"]["ip"]

 
bash "apt-get update" do
  code <<-CODE
    apt-get update
  CODE
end

package "keystone" do
	action :install
end


template "/etc/keystone/keystone.conf" do
  source "keystone/keystone.conf.erb"
  owner "root"
  group "root"
  mode "0744"
  variables ({ 
    :admin_token => admin_token,
    :keystone_user => keystone_user,
    :keystone_password => keystone_password,
    :db_ip => db_ip
  })
end


service "keystone" do
  action :restart
end

bash "synchronise keystone database" do
  code <<-CODE
    keystone-manage db_sync
  CODE
end


template "/root/creds" do
  source "keystone/creds.erb"
  owner "root"
  group "root"
  mode "0644"
  variables ({ 
    :private_ip => private_ip,
    :admin_token => admin_token,
    :admin_password => admin_password
  })
end 

template "/root/keystone.sh" do
  source "keystone/keystone.sh.erb"
  owner "root"
  group "root"
  mode "0744"
  variables ({ 
    :private_ip => private_ip,
    :public_ip => public_ip,
    :admin_token => admin_token,
    :admin_password => admin_password,
    :admin_email => admin_email,
    :nova_password => nova_password,
    :glance_password => glance_password,
    :quantum_password => quantum_password,
    :cinder_password => cinder_password,
    :swift_password => swift_password,
    :swift_proxy_ip => swift_proxy_ip
  })
end

bash "Deploy Keystone configuration" do
  code <<-CODE
    source /root/creds
    keystone tenant-list | grep admin || /root/keystone.sh
  CODE
end

bash "Delete Keystone configuration" do
  only_if("test -f /root/keystone.sh")
  code <<-CODE
    rm /root/keystone.sh
  CODE
end
