# Grizzly Variables
role = getRole
controller_role = "havana_controller_node"
mysql_root_password = ''

# Query mysql root password
partial_search(:node, "role:#{controller_role}",
  :keys => {
    'mysql_root_password'   => [ 'havana', role, 'mysql', 'root_password']
  }
).each do |result|
  mysql_root_password = result['mysql_root_password']
end

directory "/var/cache/local/preseeding/" do
  not_if("test -d /var/cache/local/preseeding")
	owner "root"
	group "root"
	mode 0755
	recursive true
end

template "/var/cache/local/preseeding/mysql-server.seed" do
	source "mysql/mysql-server.seed.erb"
	owner "root"
	group "root"
	mode "0600"
	variables ({
	  :mysql_root_password => mysql_root_password
	})
end

bash "preseed mysql" do
  code <<-CODE
   debconf-set-selections /var/cache/local/preseeding/mysql-server.seed
   CODE
end

%w{mysql-server-5.5 python-mysqldb}.each do |pkg|
  package pkg do
    action :install
  end
end

bash "Update my.cnf" do
	code <<-CODE
	 sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/my.cnf
	CODE
end

service "mysql" do
  action :restart  
end

node["havana"][role]["mysql"]["users"].each do | u |
  bash "Creating OpenStack service databases" do
    code <<-CODE
    mysql -uroot -p#{node["havana"][role]["mysql"]["root_password"]} -e "CREATE DATABASE #{u};"
    mysql -uroot -p#{node["havana"][role]["mysql"]["root_password"]} -e "GRANT ALL PRIVILEGES ON #{u}.* TO '#{u}'@'%' IDENTIFIED BY '#{node["havana"][role]["mysql"]["user_data"][u]["password"]}';"
    CODE
  end
end
