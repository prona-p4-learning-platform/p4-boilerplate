# Example 2: Minimalistic Switch (L2 Forwarding)

Basic implementation of a layer 2 switch in P4 using [p4 tutorials](https://github.com/p4lang/tutorials) environment incl. mininet.

## Usage

It's assumed that you run this example in a VM, container or host that supports the necessary P4 tools. Otherwise please install all depencies as described for p4-boilerplate and p4 tutorials (as described in the main [README](https://github.com/prona-p4-learning-platform/p4-boilerplate/blob/main/README.md)) or consider using [p4-container](https://github.com/prona-p4-learning-platform/p4-container).

```
cd p4-boilerplate/Example2-MinimalisticSwitch
make
```

This starts mininet. However, the typical mininet hello world

```
mininet> h1 ping h2
```

will not work right away, as switch starts with empty tables, that need to be filled during runtime. See [prona-switch-static-table.p4](https://github.com/prona-p4-learning-platform/p4-boilerplate/blob/main/Example2-MinimalisticSwitch/prona-switch-static-table.p4). You can run ```simple_switch_CLI``` and add the required table entries in MyIngress.dstMacAddr and possibly also a multicast group to support broadcasts. Otherwise static ARP entries etc. will be used. See [prona-minimalisticswitch.md](https://github.com/prona-p4-learning-platform/p4-boilerplate/blob/main/Example2-MinimalisticSwitch/prona-minimalisticswitch.md) for an example lab sheet.

To stop the example exit mininet. You can use ```make clean``` to clean all resources created by mininet (e.g., in case of crashes or leftover resources being still allocated).