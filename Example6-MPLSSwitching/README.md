# Example 6: Multiprotocol Lable-Switching
This example showcases how P4 can be used to implement MPLS-Switching utilizing the Network API from p4utils.

## Usage

## Topology
```mermaid
flowchart TD
    A[h1] --> B(s1)
    B --> C(s2)
    B --> F(s4)
    F --> G(s5)
    G --> H(h3)
    C --> D(s3)
    D --> E[H2]
```

The topology consists of three hosts that are connected via switches as seen in the figure above.