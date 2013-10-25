name "havana_compute_node"
description "Installs OpenStack compute node"
run_list [
  "recipe[havana::interfaces]",
  "recipe[havana::common]",
  "recipe[havana::ip_forwarding]",
  "recipe[havana::libvirt]",
  "recipe[havana::openvswitch]",
  "recipe[havana::neutron_ovs_agent]",
  "recipe[havana::nova-compute]"
]
