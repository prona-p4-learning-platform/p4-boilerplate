# Example 6: Multiprotocol Lable-Switching
This example showcases how P4 can be used to implement MPLS-Switching utilizing the Network API from p4utils.

## Usage

## Topology
```mermaid
graph LR
	A[h1] --- B[s1]
	C[h2] --- B[s1]
	B[s1] --- D[s2]
	B[s1] --- E[s4]
	D[s2] --- F[s3]
	F[s3] --- G[h3]
	E[s4] --- G[s5]
	G[s5] --- H[h3]
```

The topology consists of three hosts that are connected via switches as seen in the figure above.