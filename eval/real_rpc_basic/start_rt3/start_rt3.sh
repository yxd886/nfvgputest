#! /bin/sh

sudo rm -f ./core

ulimit -c unlimited

sudo ../../../runtime/samples/real_rpc_basic/server_main --runtime_id=3 --input_port_mac="52:54:03:00:00:01" \
--output_port_mac="52:54:03:00:00:02" --control_port_mac="52:54:03:00:00:03" --rpc_ip="127.0.0.1" --rpc_port=10242 \
--input_port="rt3_iport" --output_port="rt3_oport" --control_port="rt3_cport" --worker_core=3 --service_chain="pkt_counter,firewall"
