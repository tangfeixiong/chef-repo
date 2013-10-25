name "havana_network_node"
description "Installs OpenStack network node"
run_list [
  "recipe[havana::interfaces]",
  "recipe[havana::common]",
  "recipe[havana::ip_forwarding]",
  "recipe[havana::openvswitch]",
  "recipe[havana::neutron_agents]"
]