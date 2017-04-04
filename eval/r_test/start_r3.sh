#! /bin/sh

sudo rm -f ./core

ulimit -c unlimited

service_chain="Service chain: $2" #pkt_counter firewall

if [ "$1" -ge "1" ]
then
sudo nohup ~/nfa/runtime/samples/real_rpc_basic/server_main --runtime_id=31 --input_port_mac="52:54:03:01:00:01" \
--output_port_mac="52:54:03:01:00:02" --control_port_mac="52:54:03:01:00:03" --rpc_ip="202.45.128.156" --rpc_port=10241 \
--input_port="rt1_iport" --output_port="rt1_oport" --control_port="rt1_cport" --worker_core=1 --service_chain="${service_chain}" > /home/net/nfa/eval/r_test/rt1_log.log 2>&1 &
fi

if [ "$1" -ge "2" ]
then
sudo nohup ~/nfa/runtime/samples/real_rpc_basic/server_main --runtime_id=32 --input_port_mac="52:54:03:02:00:01" \
--output_port_mac="52:54:03:02:00:02" --control_port_mac="52:54:03:02:00:03" --rpc_ip="202.45.128.156" --rpc_port=10242 \
--input_port="rt2_iport" --output_port="rt2_oport" --control_port="rt2_cport" --worker_core=2 --service_chain="${service_chain}" > /home/net/nfa/eval/r_test/rt2_log.log 2>&1 &
fi

if [ "$1" -ge "3" ]
then
sudo nohup ~/nfa/runtime/samples/real_rpc_basic/server_main --runtime_id=33 --input_port_mac="52:54:03:03:00:01" \
--output_port_mac="52:54:03:03:00:02" --control_port_mac="52:54:03:03:00:03" --rpc_ip="202.45.128.156" --rpc_port=10243 \
--input_port="rt3_iport" --output_port="rt3_oport" --control_port="rt3_cport" --worker_core=3 --service_chain="${service_chain}" > /home/net/nfa/eval/r_test/rt3_log.log 2>&1 &
fi
