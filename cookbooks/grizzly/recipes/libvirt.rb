
# Checking VT-enabled CPU
package "cpu-checker" do
		action :install
end

bash "Checking kvm module" do
  not_if("modprobe -l | grep kvm-intel")
  code <<-CODE
    modprobe kvm_intel
    echo kvm_intel >> /etc/modules
  CODE
end

# Installing kvm and libvirt packages
%w{kvm libvirt-bin pm-utils}.each do |pkg|
  package pkg do
    action :install
  end
end

# Sanity check
%w{dbus libvirt-bin}.each do | service |
  service service do
    action :restart
  end
end

# Updating qemu device permissions
bash "Updating /etc/libvirt/qemu.conf" do
  not_if("egrep \"^cgroup\" /etc/libvirt/qemu.conf")
  code <<-CODE
    echo "cgroup_device_acl = [ \\"/dev/null\\", \\"/dev/full\\", \\"/dev/zero\\", \\"/dev/random\\", \\"/dev/urandom\\", \\"/dev/ptmx\\", \\"/dev/kvm\\", \\"/dev/kqemu\\", \\"/dev/rtc\\", \\"/dev/hpet\\", \\"/dev/net/tun\\"]" >> /etc/libvirt/qemu.conf
  CODE
end

# Deleting default virtual bridges
bash "Deleting default virtual bridges" do
  not_if("virsh net-list | grep default")
  code <<-CODE
    virsh net-destroy default
    virsh net-undefine default
  CODE
end

# Enable live migration
bash "Updating /etc/libvirt/libvirtd.conf" do
  not_if("egrep \"^listen_tls\" /etc/libvirt/libvirtd.conf")
  code <<-CODE
    sed -i 's/#listen_tls/listen_tls/' /etc/libvirt/libvirtd.conf
    sed -i 's/#listen_tcp/listen_tcp/' /etc/libvirt/libvirtd.conf
    sed -i 's/#auth_tcp = \"sasl\"/auth_tcp = \"none\"/' /etc/libvirt/libvirtd.conf
  CODE
end

# Enable live migration
bash "Updating /etc/init/libvirt-bin.conf" do
  not_if("grep \"\\-d \\-l\" /etc/init/libvirt-bin.conf")
  code <<-CODE
    sed -i 's/libvirtd_opts=\"-d\"/libvirtd_opts=\"-d -l\"/' /etc/init/libvirt-bin.conf
  CODE
end

# Enable live migration
bash "Updating /etc/default/libvirt-bin" do
  not_if("grep \"\\-d \\-l\" /etc/default/libvirt-bin")
  code <<-CODE
    sed -i 's/libvirtd_opts=\"-d\"/libvirtd_opts=\"-d -l\"/' /etc/default/libvirt-bin
  CODE
end


%w{dbus libvirt-bin}.each do | service |
  service service do
    action :restart
  end
end
