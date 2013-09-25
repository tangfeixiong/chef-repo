name "controller_node"
description "Installs OpenStack controller node"
run_list [
  "recipe[grizzly::default]",
  "recipe[grizzly::interfaces]",
  "recipe[grizzly::common]",
  "recipe[grizzly::mysql_server]",
  "recipe[grizzly::rabbitmq_server]",
  "recipe[grizzly::ip_forwarding]",
  "recipe[grizzly::keystone]",
  "recipe[grizzly::glance]",
  "recipe[grizzly::quantum_server]",
  "recipe[grizzly::nova]",
  "recipe[grizzly::cinder]",
  "recipe[grizzly::horizon]",
  "recipe[grizzly::controller_scripts]"
]
