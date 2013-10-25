# TODO
# Change also password in
#  /etc/glance/glance-api-past.ini and /etc/glance/glance-registry-paste.ini

# Glance variables
role = getRole
glance_user = "glance"
glance_password = node["havana"][role][glance_user]["password"]
mysql_glance_password = node["havana"][role]["mysql"]["user_data"][glance_user]["password"]
private_ip = node["havana"][role]["network"]["private"]["ip"]
swift_store_auth_address = node["havana"][role]["glance"]["swift_store_auth_address"]
swift_store_tenant = node["havana"][role]["glance"]["swift_store_tenant"]
swift_store_user = node["havana"][role]["glance"]["swift_store_user"]
swift_store_password = node["havana"][role]["glance"]["swift_store_password"]


# Install glance
package "glance" do
	action :install
end

# Glance api and registry
%w{glance-api glance-registry}.each do | glance_service |
  template "/etc/glance/#{glance_service}.conf" do
    source "glance/#{glance_service}.conf.erb"
    owner "root"
    group "root"
    mode "0744"
    variables ({ 
      :glance_user => glance_user,
      :mysql_glance_password => mysql_glance_password,
      :db_ip => private_ip,
      :glance_user => glance_user,
      :glance_password => glance_password,
      :auth_host => private_ip,
      :swift_store_auth_address => swift_store_auth_address,
      :swift_store_tenant => swift_store_tenant,
      :swift_store_user => swift_store_user,
      :swift_store_password => swift_store_password
    })
  end
end

# Glance api paste and registry paste
%w{glance-api glance-registry}.each do | glance_service |
  template "/etc/glance/#{glance_service}-paste.ini" do
    source "glance/#{glance_service}-paste.ini.erb"
    owner "root"
    group "root"
    mode "0744"
    variables ({ 
      :glance_user => glance_user,
      :glance_password => glance_password,
      :auth_host => private_ip
    })
  end
end


# Restart glance services
%w{glance-api glance-registry}.each do | glance_service |
  service glance_service do
    action :restart 
  end
end

# Populate glance database
bash "synchronise glance database" do
  code <<-CODE
    glance-manage db_sync
  CODE
end

# Add glance images
node["havana"][role]["glance"]["image-names"].each do | img |
  image = node["havana"][role]["glance"]["image-data"][img]
  bash "adding image #{img}" do
    code <<-CODE
      source /root/creds
      glance image-list | grep #{img} || glance image-create --name #{img} --is-public true --container-format #{image["container_format"]} --disk-format #{image["disk_format"]} --location #{image["url"]}
    CODE
  end
end

