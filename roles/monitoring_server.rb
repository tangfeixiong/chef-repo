name "monitoring_server"
description "Monitoring server"
run_list [
  "recipe[nagios::server]",
  "recipe[rsyslog::server]",
  "recipe[nagios::apache]",
  "recipe[ganglia]",
  "recipe[ganglia::web]",
  "recipe[ganglia::graphite]",
  "recipe[splunk::server]"
]

override_attributes "nagios" => {
    "server_auth_method" => "htauth"
  },
  "rsyslog" => {
    "server_ip" => "199.34.121.38"
}