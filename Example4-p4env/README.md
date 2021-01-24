# Example p4environment

This example uses the p4environment (p4env) developed at NetLab of Fulda University of Applied Sciences. p4env contains a comprehensive framework leveraring the P4 toolchain to build and run P4 programs, topologies (based on mininet), switches, controllers and monitors. This example provides an empty setup as a starting point. Detailed documentation and example usage is provided at: <https://gitlab.cs.hs-fulda.de/flow-routing/cnsm2020/p4environment>

## Usage

It's assumed that you run this example in a VM, container or host that supports the necessary P4 tools. Otherwise please install all depencies as described for p4-boilerplate and p4environment (as described in the main [README](https://github.com/prona-p4-learning-platform/p4-boilerplate/blob/main/README.md)) or consider using [p4-container](https://github.com/prona-p4-learning-platform/p4-container). If you choose p4-container, be advised, that its support to run p4environment is limited, due to limitations for netem and openvswitch inside typical container environments.

```
cd p4-boilerplate/Example4-p4env
sudo python p4runner.py
```

This starts the framework and drops you to a mininet console. The typical mininet hello world

```
mininet> h1 ping h2
```

should work, but you should take a look at <https://gitlab.cs.hs-fulda.de/flow-routing/cnsm2020/p4environment> for proper setup of research experiments or teaching labs with p4environment as it offers a complete framework to run network topologies with custom hosts and switches, controllers and monitors using custom P4 programs and host as well as switch initialization.

To stop the example exit mininet.