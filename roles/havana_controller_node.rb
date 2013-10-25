name "havana_controller_node"
description "Installs OpenStack controller node"
run_list [
  "recipe[havana::default]",
  "recipe[havana::interfaces]",
  "recipe[havana::common]",
  "recipe[havana::mysql_server]",
  "recipe[havana::rabbitmq_server]",
  "recipe[havana::ip_forwarding]",
  "recipe[havana::keystone]",
  "recipe[havana::glance]",
  "recipe[havana::nova]",
  "recipe[havana::horizon]",
  "recipe[havana::cinder]",
  "recipe[havana::neutron_server]",
  "recipe[havana::controller_scripts]"
]
