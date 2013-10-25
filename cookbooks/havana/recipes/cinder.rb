# Cinder Variables
role = getRole
private_ip = node["havana"][role]["network"]["private"]["ip"]
cinder_user = "cinder"
cinder_password = node["havana"][role][cinder_user]["password"]
cinder_iscsi_target_path = node["havana"][role][cinder_user]["iscsi_target_path"]
mysql_cinder_password = node["havana"][role]["mysql"]["user_data"][cinder_user]["password"]
cinder_iscsi_target_path = node["havana"][role][cinder_user]["iscsi_target_path"]
cinder_iscsi_target_ip = node["havana"][role][cinder_user]["iscsi_target_ip"]
device = ""
dev = ""

# Install packages
%w{cinder-api cinder-scheduler cinder-volume iscsitarget iscsitarget-dkms}.each do |pkg|
  package pkg do
   action :install
  end
end

# Enable iscsi
bash "enable iscsi" do
  code <<-CODE
   sed -i 's/ISCSITARGET_ENABLE=false/ISCSITARGET_ENABLE=true/g' /etc/default/iscsitarget
  CODE
end

# Disable tgt service
service "tgt" do
  action :stop
end

# Restart iscsi services
%w{iscsitarget open-iscsi}.each do |srv|
  service srv do
    action :restart
  end
end

template "/etc/cinder/api-paste.ini" do
  source "cinder/api-paste.ini.erb"
  owner "cinder"
  group "cinder"
  mode "0600"
  variables ({ 
    :auth_host => private_ip,
    :service_host => private_ip,
    :cinder_user => cinder_user,
    :cinder_password => cinder_password
  })
end


template "/etc/cinder/cinder.conf" do
	source "cinder/cinder.conf.erb"
  owner "cinder"
	group "cinder"
	mode "0644"
	variables ({ 
    :private_ip => private_ip,
    :cinder_password => mysql_cinder_password,
    :cinder_user => cinder_user,
    :rabbit_host => private_ip
  })
end


bash "syncronise cinder database" do
  code <<-CODE
    cinder-manage db sync
  CODE
end


if cinder_iscsi_target_path.empty?
  dev = "loop2"
  device = "/dev/#{dev}p1"

  bash "Creating local storage path" do
    not_if "test -d /data/cinder"
    code <<-CODE
      mkdir /data/cinder/
    CODE
  end

  bash "Creating local storage file" do
    not_if "test -e /data/cinder/cinder-volumes"
    code <<-CODE
      dd if=/dev/zero of=/data/cinder/cinder-volumes bs=1 count=0 seek=10G
    CODE
  end

  bash "Attaching /dev/#{dev} into the storage file" do
    not_if "losetup /dev/#{dev}"
    code <<-CODE
      losetup /dev/#{dev} /data/cinder/cinder-volumes
    CODE
  end

  bash "Creating storage partition" do
  not_if "parted -s -- /dev/#{dev} print"
  code <<-CODE
      parted -s -- /dev/#{dev} mklabel gpt
      parted -s -- /dev/#{dev} mkpart primary 1 -1 
      parted -s -- /dev/#{dev} set 1 lvm on
    CODE
  end

else
  device = "/dev/sdb1"
  
  bash "Discovering iSCSI target" do
    not_if "iscsiadm -m iface -P 1 | grep #{cinder_iscsi_target_ip}"
    code <<-CODE
      iscsiadm -m discovery -t sendtargets -p #{cinder_iscsi_target_ip}
    CODE
  end

  bash "Connecting iSCSI target" do
    code <<-CODE
      iscsiadm --mode node --targetname #{cinder_iscsi_target_path} --portal #{cinder_iscsi_target_ip}:3260 --login
    CODE
  end

  bash "Creating storage partition" do
    not_if "parted -s -- /dev/sdb print | grep lvm"
    code <<-CODE
      parted -s -- /dev/sdb mklabel gpt
      parted -s -- /dev/sdb mkpart primary 1 -1 
      parted -s -- /dev/sdb set 1 lvm on
    CODE
  end
  
end

bash "Creating Physical Volume" do
  not_if "pvdisplay  #{device}"
  code <<-CODE
    pvcreate #{device}
  CODE
end

bash "Creating Volume Group" do
  only_if "pvdisplay  #{device}"
  not_if "vgdisplay cinder-volumes"
  code <<-CODE
    vgcreate cinder-volumes #{device}
  CODE
end


%w{cinder-api cinder-scheduler cinder-volume}.each do |srv|
	service srv do
		action :restart
	end
end
