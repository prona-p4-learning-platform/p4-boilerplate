# ProNA p4-boilerplate

Currently p4-boilerplate uses the p4-tutorials, nsg-ethz [p4-learning](https://github.com/nsg-ethz/p4-learning) and the [P4Environment](https://gitlab.cs.hs-fulda.de/flow-routing/cnsm2020/p4environment) of Fulda University of Applied Sciences. It serves as a basis for P4 based labs in the masters' course Advanced Computer Networks of the NetLab @ Fulda University of Applied Sciences and in the research Project ProNA.

## Installation

Install the [p4-tutorials VM](https://github.com/p4lang/tutorials) or setup a Linux host with the provided [bootstrap](https://github.com/p4lang/tutorials/tree/master/vm) scripts (you can find pre-build VM images in the Web (e.g., [here](https://p4.org/events/2019-04-30-p4-developer-day/)), but we recommend building a fresh install). 

```
git clone https://github.com/prona-p4-learning-platform/p4-boilerplate
git clone https://github.com/p4lang/tutorials
ln -s tutorials/utils utils
```

For testing and non-production setups, we also provide a container image containing the necessary toolchain, dependencies and lab material: [p4-container](https://github.com/prona-p4-learning-platform/p4-container)

The container image can be run by using:

```
docker pull prona/p4-container
docker run -it --rm --privileged prona/p4-container
```
For additional details, see [p4-container](https://github.com/prona-p4-learning-platform/p4-container).

## Usage Example

```
cd p4-boilerplate/Example1-Repeater
make
make clean
```

For further information, please see usage and examplary lab sheet the provided Examples:

* [Example1-Repeater](https://github.com/prona-p4-learning-platform/p4-boilerplate/tree/main/Example1-Repeater)
* [Example2-MinimalisticSwitch](https://github.com/prona-p4-learning-platform/p4-boilerplate/tree/main/Example2-MinimalisticSwitch)
* [Example3-LearningSwitch](https://github.com/prona-p4-learning-platform/p4-boilerplate/tree/main/Example3-LearningSwitch)
* [Example4-p4env](https://github.com/prona-p4-learning-platform/p4-boilerplate/tree/main/Example4-p4env)

p4-boilerplate is used together with [learn-sdn-hub](https://github.com/prona-p4-learning-platform/learn-sdn-hub), [p4-container](https://github.com/prona-p4-learning-platform/p4-container) and [P4Environment](https://gitlab.cs.hs-fulda.de/flow-routing/cnsm2020/p4environment) in the research digLL Project ProNA of Hochschule Darmstadt University of Applied Sciences and NetLab @ Fulda University of Applied Sciences.