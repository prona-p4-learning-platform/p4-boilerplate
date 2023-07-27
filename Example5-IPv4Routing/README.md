# Example 5: Simple IP Routing
This example uses the new Network API from p4utils to implement very basic IPv4 Routing on Switches.
The Network API provides a simple yet powerful way to define network topology and provide p4 programs or setup commands to network components.
A detailed documentation of the Network API can be found [here](https://nsg-ethz.github.io/p4-utils/introduction.html).

# Usage
It's assumed that you run this example in a VM, container or host that supports the necessary P4 tools. Otherwise please install all depencies as described for p4-boilerplate and p4environment (as described in the main README) or consider using p4-container. If you choose p4-container, be advised, that its support to run p4environment is limited, due to limitations for netem and openvswitch inside typical container environments.
```
cd p4-boilerplate/Example5-IPRouting
sudo python3 network.py
```
This sets up the topology and drops you to a mininet console. The typical mininet hello world
```
mininet> h1 ping h2
```
should work, although you should take a look at the p4 source and the commands in commands-s1.txt and commands-s2.txt aswell as the topology in network.py, where you can modify the topology and the setup commands for each switch.
Pinging other hosts might require adding additional static table entries.

To exit the example, simple exit mininet
