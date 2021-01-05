# ProNA p4-boilerplate

Currently the boilerplate uses the p4-tutorials toolchain. It will be updated to either use [P4Environment](https://gitlab.cs.hs-fulda.de/flowrouting/p4environment) of Fulda University of Applied Sciences or nsg-ethz [p4-learning](https://github.com/nsg-ethz/p4-learning) environment.

## Installation

Install the [p4-tutorials VM](https://github.com/p4lang/tutorials) or setup a Linux host with the provided [bootstrap](https://github.com/p4lang/tutorials/tree/master/vm) scripts (you can find pre-build VM images in the Web (e.g., [here](https://p4.org/events/2019-04-30-p4-developer-day/)), but we recommend building a fresh install). 

```
git clone https://github.com/prona-p4-learning-platform/p4-boilerplate
git clone https://github.com/p4lang/tutorials
cp -a tutorials/utils .
```

## Usage Example

```
cd p4-boilerplate/Example1-Repeater
make
```
