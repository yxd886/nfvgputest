#! /bin/sh

sudo rm -f ./core

ulimit -c unlimited

sudo ../../../runtime/samples/real_rpc_basic/server_main --runtime_id=2 --input_port_mac="52:54:02:00:00:01" \
--output_port_mac="52:54:02:00:00:02" --control_port_mac="52:54:02:00:00:03" --rpc_ip="202.45.128.155" --rpc_port=10241 \
--input_port="rt2_iport" --output_port="rt2_oport" --control_port="rt2_cport" --worker_core=2 --service_chain="pkt_counter,firewall"
