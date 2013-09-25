bash "Enable ip forwarding" do
  not_if("sysctl net.ipv4.ip_forward | grep 1")
  code <<-CODE
  sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
  sysctl net.ipv4.ip_forward=1
  CODE
end

