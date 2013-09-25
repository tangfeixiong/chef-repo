name "firewall"
description "Firewall role"
run_list [
  "recipe[ufw::default]"
]
override_attributes "firewall" => {
  "rules" => [
    {"Allow access from private range 192.168.100.0/24" => {
        "source" => "192.168.100.0/24",
        "action" => "allow"
      }
    },
    {"Allow access from public range 199.34.121.32/27" => {
        "source" => "199.34.121.32/27",
        "action" => "allow"
      }
    },
    {"Allow access from floating IP range 198.36.127.16/28" => {
        "source" => "198.36.127.16/28",
        "action" => "allow"
      }
    },
    {"apache" => {
          "port" => "80"
      }
    },
    {"rsyslog" => {
          "port" => "514"
      }
    },
    {"nagios3" => {
          "port" => "81"
      }
    },
    {"chef" => {
          "port" => "20443"
      }
    },
    {"keystone" => {
          "port" => "5000"
      }
    },
    {"vnc" => {
          "port" => "6080"
      }
    },
    {"gmetad" => {
          "port" => "8651"
      }
      
    },
    {"gmetad" => {
          "port" => "8652"
      }
      
    },
    {"gmond" => {
          "port" => "8649"
      }
    },
    {"splunk" => {
          "port" => "8090"
      }
    }
  ]
}