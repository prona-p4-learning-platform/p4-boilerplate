# Example 1: Repeater (aka Hub)

Basic implementation of a repeater/hub in P4 using [p4 tutorials](https://github.com/p4lang/tutorials) environment incl. mininet.

## Usage

It's assumed that you run this example in a VM, container or host that supports the necessary P4 tools. Otherwise please install all depencies as described for p4-boilerplate and p4 tutorials (as described in the main [README](https://github.com/prona-p4-learning-platform/p4-boilerplate/blob/main/README.md)) or consider using [p4-container](https://github.com/prona-p4-learning-platform/p4-container).

```
cd p4-boilerplate/Example1-Repeater
make
```

This starts mininet and you should be able to do the typical mininet hello world

```
mininet> h1 ping h2
```

You can experiment by changing the p4 code in [prona-repeater.p4](https://github.com/prona-p4-learning-platform/p4-boilerplate/blob/main/Example1-Repeater/prona-repeater.p4) and rerunning make. See [prona-repeater.md](https://github.com/prona-p4-learning-platform/p4-boilerplate/blob/main/Example1-Repeater/prona-repeater.md) for an example lab sheet.

To stop the example exit mininet. You can use ```make clean``` to clean all resources created by mininet (e.g., in case of crashes or leftover resources being still allocated).