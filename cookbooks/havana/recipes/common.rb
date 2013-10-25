bash "Add Havana repository" do
  not_if("grep havana /etc/apt/sources.list.d/havana.list")
  code <<-CODE
  echo "deb http://ubuntu-cloud.archive.canonical.com/ubuntu precise-updates/havana main" >> /etc/apt/sources.list.d/havana.list
  CODE
end

bash "apt-get update" do
  code <<-CODE
    apt-get update
  CODE
end

# Install common packages
%w{ubuntu-cloud-keyring vlan bridge-utils joe lvm2 open-iscsi open-iscsi-utils}.each do |pkg|
  package pkg do
    action :install
  end
end

bash "apt-get update" do
  code <<-CODE
    apt-get update
  CODE
end
