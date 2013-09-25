TODO
=====

- Add swift nagios check "check_swift-proxy_process.json":

	{
		"id": "swift-proxy_process",
		"hostgroup_name": "swift_proxy_node",
		"command_line": "$USER1$/check_nrpe -H $HOSTADDRESS$ -c check_swift-proxy_process"
	}

