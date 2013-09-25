name "swift_proxy_node"
description "Installs OpenStack Swift Proxy node"
run_list [
             "recipe[grizzly::swift_proxy]"
]
