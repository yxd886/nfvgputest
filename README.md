# nfa

The project relies on the C++ implementation of BESS.

To build C++ branch of BESS, the following things must be installed.

1. grpc must be intalled first according to https://github.com/grpc/grpc/blob/master/INSTALL.md.

2. After installing grpc, should install protocol buffer from the third_party directory of grpc.

3. Need to install libssl-dev libunwind8-dev liblzma-dev.

# Some notes for using DPDK mem_buf.


1. Use clone to create a copy of a rte_mbuf. It is super fast, no data copy.
