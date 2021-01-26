# Example 3: Learning Switch (L2 Forwarding incl. Flood & Filter)

Basic implementation of a layer 2 learning switch in P4 using [p4 tutorials](https://github.com/p4lang/tutorials) environment incl. mininet. The switch offers rudimentary support for common flood & filter approach of layer 2 switches. To learn destination MAC addresses, a controller app is included. Learned destination MAC addresses will be filtered and hence traffic will only be forwarded to the port this MAC address is located at. As this is a basic implementation, intentionally no aging/moving for MAC addresses, VLAN associations etc. are supported.

This lab is based on the [p4-learning](https://github.com/nsg-ethz/p4-learning) environment. You can find further details regarding the implementation of a learning switch in the corresponding [exercise](https://github.com/nsg-ethz/p4-learning/tree/master/exercises/04-L2_Learning) by NSG-ETHZ.

## Usage

It's assumed that you run this example in a VM, container or host that supports the necessary P4 tools. Otherwise please install all depencies as described for p4-boilerplate and p4-learning (as described in the main [README](https://github.com/prona-p4-learning-platform/p4-boilerplate/blob/main/README.md)) or consider using [p4-container](https://github.com/prona-p4-learning-platform/p4-container). Especially, you need to install [p4-utils](https://github.com/nsg-ethz/p4-utils).

```
cd p4-boilerplate/Example3-LearningSwitch
sudo p4run
```

This starts mininet. However, the typical mininet hello world

```
mininet> h1 ping h2
```

will not work right away, as switch starts with empty tables, that need to be filled during runtime. See [prona-switch-learning.p4](https://github.com/prona-p4-learning-platform/p4-boilerplate/blob/main/Example3-LearningSwitch/p4src/prona-switch-learning.p4). 

Run the provided controller app based on the p4-learning example in another terminal using 

```
sudo python learning_switch_controller_app.py s1
```

with s1 being the switch that table entries should be added to by the controller. Start the ping from h1 to h2 and see table entries being added. Meanwhile, you can also try to sniff packets on h3, to see flooding & filtering being applied similar to a basic real-world layer 2 switch. See [prona-learningswitch.md](https://github.com/prona-p4-learning-platform/p4-boilerplate/blob/main/Example3-LearningSwitch/prona-learningswitch.md) for an example lab sheet.

You can use tmux to start mininet and learning_switch_controller_app.py together. E.g., by using:

```
#!/bin/bash
tmux new-session -d bash
tmux split-window -h bash
tmux send -t 0:0.0 "sudo p4run" C-m
while ! sudo netstat -tapen | grep -i listen | grep 9090; do
  sudo netstat -tapen
  sleep 1
done
tmux send -t 0:0.1 "sudo python learning_switch_controller_app.py s1" C-m
tmux -2 attach-session -d
```

To stop the example exit mininet and stop the controller app.