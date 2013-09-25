centos_lamp54 Cookbook
======================

This cookbook installs and configures apache 2.x, MySQL 5.5 and PHP5.4 with serveral extensions.

Requirements
============

This cookbook was designed and tested on CentOS 6.x 

Attributes
=========

This cookbook uses a Chef enrvironemnt JSON instead of attributes.

Usage
=====

Export your chef repository:

	export CHEF_REPO=/path/to/your/chef/repository

Create a role to install the environemnt:


	cat << EOF > $CHEF_REPO/roles/centos_lamp54.rb
	name "centos_lamp54"
	description "baremetalcloud LAMP environment. Apache 2.x, MySQL 5.5 and PHP 5.4"
	run_list [
		"recipe[centos_lamp54::common]",
		"recipe[centos_lamp54::repositories]",
		"recipe[centos_lamp54::mysql]",
		"recipe[centos_lamp54::php]",
		"recipe[centos_lamp54::apache]"
	]
	EOF


Create the environment JSON:

	cat << EOF > $CHEF_REPO/environments/centos_lamp54.json
	{
    "name": "centos_lamp54_env",
    "description": "baremetalcloud LAMP environment. Apache 2.x, MySQL 5.5 and PHP 5.4",
    "cookbook_versions": {},
    "json_class": "Chef::Environment",
    "chef_type": "environment",
    "default_attributes": {},
    "override_attributes": {
        "php": [
            "php54w",
            "php54w-bcmath",
            "php54w-cli",
            "php54w-common",
            "php54w-dba",
            "php54w-devel",
            "php54w-embedded",
            "php54w-enchant",
            "php54w-fpm",
            "php54w-gd",
            "php54w-imap",
            "php54w-interbase",
            "php54w-intl",
            "php54w-ldap",
            "php54w-mbstring",
            "php54w-mcrypt",
            "php54w-mssql",
            "php54w-mysql55",
            "php54w-odbc",
            "php54w-pdo",
            "php54w-pecl-memcache",
            "php54w-pecl-zendopcache",
            "php54w-pecl-xdebug",
            "php54w-pgsql",
            "php54w-process",
            "php54w-pspell",
            "php54w-recode",
            "php54w-snmp",
			"php54w-soap",
			"php54w-tidy",
			"php54w-xml",
			"php54w-xmlrpc",
			"php54w-zts",
			"libssh2-devel"
	        ],
        	"pecl": [
	            "ssh2-beta"
        	],
	        "packages": [
        	    "gcc",
	            "make"
        	],
	        "rpm": [
        	    "http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm",
	            "http://rpms.famillecollet.com/enterprise/remi-release-6.rpm",
        	    "http://mirror.webtatic.com/yum/el6/latest.rpm"
	        ],
        	"mysql": {
	            "password": "foo"
        	}
	    }
	}
	EOF


Upload your cookbook:

	knife cookbook upload centos_lamp54

Upload role:

	knife role from file $CHEF_REPO/roles/centos_lamp54.rb

Upload environmnet:

	knife environment from file $CHEF_REPO/environments/centos_lamp54.json

Bootstrap your node:
	
	knife bootstrap <IP> -N <node_name> -x root -P <password> -r 'role[centos_lamp54]' -E 'centos_lamp54_env'

Run `chef-client` on your node.


Contributing
===========

e.g.
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write you change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Author
==================

Author:: Diego Desani (<diego@baremetalcloud.com>)

Copyright:: 2013, baremetalcloud Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
