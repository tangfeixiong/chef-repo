name "grizzly_swift_proxy_node"
description "Installs OpenStack Swift Proxy node"
run_list [
             "recipe[grizzly::swift_proxy]",
             "recipe[ufw::default]",
             "recipe[rsyslog::client]",
             "recipe[nagios::client]"
         ]
