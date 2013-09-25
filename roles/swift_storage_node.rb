name "swift_storage_node"
description "Installs OpenStack Swift Storage node"
run_list [
	"recipe[ufw::default]",
	"recipe[grizzly::swift_storage]"
]
override_attributes "firewall" => {
  "rules" => [
    {"swift object" => {
          "port" => "6000"
      }
    },
    {"swift container" => {
          "port" => "6001"
      }
    },
    {"swift account" => {
          "port" => "6002"
      }
    }
  ]
}
