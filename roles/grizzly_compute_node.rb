name "compute_node"
description "Installs OpenStack compute node"
run_list [
             "recipe[grizzly::interfaces]",
             "recipe[grizzly::common]",
             "recipe[grizzly::ip_forwarding]",
             "recipe[grizzly::libvirt]",
             "recipe[grizzly::openvswitch]",
             "recipe[grizzly::quantum_ovs_agent]",
             "recipe[grizzly::nova-compute]"
]
