# Ganglia Variables
ganglia_username = node["ganglia"]["username"]
ganglia_password = node["ganglia"]["password"]

directory "/etc/ganglia-webfrontend"

case node[:platform]
when "ubuntu", "debian"
  package "ganglia-webfrontend"
  
  execute "Generate htpasswd file" do
    command "htpasswd -cb /etc/ganglia/htpasswd.users #{ganglia_username} #{ganglia_password}"
  end
  
  template "/etc/apache2/sites-available/ganglia.conf" do
    source "apache_ganglia.conf.erb"
    owner "root"
    group "root"
    mode "0644"
  end
  
  execute "Enable ganglia site" do
    command "/usr/sbin/a2ensite ganglia.conf"
  end
  
=begin  
  link "/etc/apache2/sites-enabled/ganglia" do
    to "/etc/ganglia-webfrontend/apache.conf"
    notifies :restart, "service[apache2]"
  end

when "redhat", "centos", "fedora"
  package "httpd"
  package "php"
  include_recipe "ganglia::source"
  include_recipe "ganglia::gmetad"

  execute "copy web directory" do
    command "cp -r web /var/www/html/ganglia"
    creates "/var/www/html/ganglia"
    cwd "/usr/src/ganglia-#{node[:ganglia][:version]}"
  end
  
=end
end


service "apache2" do
  service_name "httpd" if platform?( "redhat", "centos", "fedora" )
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :restart ]
end
