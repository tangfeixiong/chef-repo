  Chef 11 OpenStack repository
===================================


Overview
--------

Every Chef installation needs a Chef Repository. This is the repository that **baremetalcloud** have setup to help users to deploy OpenStack clusters.
It currently supports Ubuntu 12.04 and installs OpenStack Grizzly version.

The installation is based on an environment file that has definitions for Compute, Network, Image, Block Storage and Monitoring services, which can be customized for each deployment. This give us the flexibility to create OpenStack clusters as a service.


Repository Cookbooks
--------------------

This repository contains several cookbooks that orchestrate OpenStack services and their monitoring installation. Here is a summary of these two types of ser:

* `grizzly` - OpenStack Grizzly cookbook.
* `nagios, ganglia, ryslog and splunk` - Monitoring cookbooks.


Usage - Deploying at baremetalcloud
---------------------------------------

From **baremetalcloud** web panel, the entire cluster can be deployed in within 30 minutes. This procedure can be easily done considering that you have an active account. These are the steps:

1. Go to https://noc.baremetalcloud.com and login.
2. Click on `Add Server` and select your configuration:
![alt foo](http://www.baremetalcloud.com/downloads/github/01.png)

3. Choose `Ubuntu 12.04 Chef 11` image 
![alt foo](http://www.baremetalcloud.com/downloads/github/02.png)
 
4. Your server will be added and its `status` will be set to `Restoring Clonezilla Image`. Click on `Edit`:
![alt foo](http://www.baremetalcloud.com/downloads/github/03.png)

5. Name it as `controller`:
![alt foo](http://www.baremetalcloud.com/downloads/github/04.png)

6. While it is restoring Ubuntu 12.04 Chef 11 image, click on `Add Server` and add two more servers:
![alt foo](http://www.baremetalcloud.com/downloads/github/05.png)

7. Select `Ubuntu 12.04 Cloud` image:
![alt foo](http://www.baremetalcloud.com/downloads/github/06.png)

8. Name them as `network` and `compute-001`:
![alt foo](http://www.baremetalcloud.com/downloads/github/07.png)
![alt foo](http://www.baremetalcloud.com/downloads/github/08.png)

9. These three servers will restore their images:
![alt foo](http://www.baremetalcloud.com/downloads/github/09.png)

10. Make sure their status are `Active` and their credentials were generated.
![alt foo](http://www.baremetalcloud.com/downloads/github/10.png)

11. Click on `Cluster` tab then `Add Cluster`:
![alt foo](http://www.baremetalcloud.com/downloads/github/11.png)

12. Add a new `OpenStack` cluster and set a name:
![alt foo](http://www.baremetalcloud.com/downloads/github/12.png)

13. A JSON will be generated and it will be used as a Chef environment:
![alt foo](http://www.baremetalcloud.com/downloads/github/13.png)

14. Connect into `controller` server via ssh.
15. Clone the github repository:

	`cd /etc/chef-server/`
	
	`git clone https://github.com/baremetalcloud/chef-repo.git`


16. Paste the JSON into the environment file: `/etc/chef-server/chef-repo/environments/controller_node_env.json`.
17. Initiate the installation

	`./init.sh`


In addiction to this, we have made a video showing these steps that might help the understanding of *baremetalcloud*'s web interface:

		**ADD HERE THE INSTALLATION VIDEO**
--


Usage - without baremetalcloud web panel
------------------------------------------

The OpenStack Grizzly cookbook requires three servers: `controller`, `network` and `compute-001` for the first installation. These servers' name should be reachable from the controller node.

Access your `controller` node and clone this github repository:


	cd /etc/chef-server/
	git clone https://github.com/baremetalcloud/chef-repo.git
	
Now customize the environment file using the example located at `environments/controller_node_env-example.json` and run:

	./init.sh



License and Author
------------------

Author:: JP Gagne (<jp@baremetalcloud.com>)

Author:: Diego Desani (<diego@baremetalcloud.com>)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
