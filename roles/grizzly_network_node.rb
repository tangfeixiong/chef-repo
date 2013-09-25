name "network_node"
description "Installs OpenStack network node"
run_list [
             "recipe[grizzly::interfaces]",
             "recipe[grizzly::common]",
             "recipe[grizzly::ip_forwarding]",
             "recipe[grizzly::openvswitch]",
             "recipe[grizzly::quantum_agents]"
]