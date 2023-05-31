# Beispiel 0: SDN Einführung

## Mininet

* Verschaffen Sie sich einen Überblick über die Funktionen von mininet (http://mininet.org/) und wie es zum Experimentieren mit SDN verwendet werden kann.
* Starten Sie mininet mit ```sudo mn```.
* Experimentieren Sie mit den folgenden Befehlen:

```	
    mininet> help
	
	mininet> (dump | net | nodes | links | ports)
	mininet> h1 (ifconfig | arp | route | tcpdump | ...)
	mininet> pingall
	mininet> h1 ping h2
	mininet> iperf h1 h2
	mininet> link s1 h1 (down | up)
```

* Stop mininet by using ```exit```. You can also cleanup previous mininet runs by using ```sudo mn -c```. See ```sudo mn --help``` for further options.
* Beenden Sie Mininet mit ```exit```. Mit dem Befehl ```sudo mn -c``` können Sie alle laufenden Mininet-Instanzen beenden. Siehe ```sudo mn --help`` für weitere Optionen.
* Starten Sie Mininet für verschiedene Topologien:

```
    sudo mn --topo single,4
	sudo mn --topo linear,4
	sudo mn --topo tree,depth=2,fanout=4
```

* Wie hängt Mininet mit Software-defined Networking zusammen?
* Wie sieht eine typische SDN-Architektur aus und welche Rolle spielen Switches und Controller?

## Mininet zusammen mit einem SDN controller verwenden

* Starten Sie mininet mit der in OpenFlowTopo.py benutzerdefinierten Topologie

```
	sudo python OpenFlowTopo.py
```

* Why do you get a warning regarding missing connection to 127.0.0.1:6633? Examine the code in OpenFlowTopo.py.
* Get an idea about what ryu (https://ryu-sdn.org/) does and how it can be used to experiment with SDN.
* Start the ryu controller together with the provided OpenFlowApp.py

```
	sudo ryu-manager OpenFlowApp.py
```

* Change the OpenFlowApp.py to install flows that enable ping (ICMP) between the hosts in the topology. Hint: Ethertype IPv4 = 0x0800 and Ethertype ARP = 0x0806.
