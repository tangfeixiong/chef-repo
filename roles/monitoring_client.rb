name "monitoring_client"
description "Monitoring client"
run_list [
  "recipe[rsyslog::client]",
  "recipe[nagios::client]",
  "recipe[ganglia]"
]

