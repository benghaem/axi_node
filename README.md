# UT ECE Verification of Digital Systems Final Project
## Formal Verification of an AXI4 Interconnect

To run the following project please do the following:

`git clone https://github.com/benghaem/axi_node`
`cd axi_node`
`git submodule update --init`
`cd formal`
`module load cadence/2016 # or equiv`
`make`

# AXI Interconnect

This is an implementation of an AXI interconnect with configurable number of
slave and master ports. The AXI interconnect supports multiple regions and
allows runtime configuration of the memory map via AXI or APB.

It was written for the use in the [PULP platform](http://pulp.ethz.ch/).

