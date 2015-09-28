fuel-plugin-network-node
============

Fuel plugin to seperate the network agent on the their own nodes. 

Summary
-------

The plugin will disable the L3, metatdata and DHCP agents on the openstack controllers, 
and install and configure the agents on a new network-node role that is created.

Usage
-----

The plugin must be installed and turned on prior to adding the controllers to the fuel
environment to ensure that the deployment task are created correctly.

Building the Plugin
-------------------
1. Clone the fuel-plugin repo from:

    ``git clone https://github.com/p5ntangle/fuel-plugin-network-node``

2. Install the Fuel Plugin Builder:

    ``pip install fuel-plugin-builder``

3. Build Network Node Fuel plugin:

   ``fpb --build fuel-plugin-network-node/``

4. The network-plugin-<x.x.x>.rpm plugin package will be created in the plugin folder
   (fuel-plugin-network/).

5. Move this file to the Fuel Master node with secure copy (scp):

   ``scp network-node-<x.x.x>.rpm root@:<the_Fuel_Master_node_IP address>:/tmp``
   ``cd /tmp``

6. Install the Network Node plugin:

   ``fuel plugins --install network-plugin-<x.x.x>.rpm``

6. Plugin is ready to use and can be enabled on the Settings tab of the Fuel web UI.


