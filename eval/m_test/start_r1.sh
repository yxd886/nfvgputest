#! /bin/sh

sudo rm -f ./core

ulimit -c unlimited

sudo nohup ../../runtime/samples/real_rpc_basic/server_main --runtime_id=11 --input_port_mac="52:54:01:01:00:01" \
--output_port_mac="52:54:01:01:00:02" --control_port_mac="52:54:01:01:00:03" --rpc_ip="202.45.128.154" --rpc_port=10241 \
--input_port="rt1_iport" --output_port="rt1_oport" --control_port="rt1_cport" --worker_core=1 > rt1_log.log 2>&1 &

if [ "$1" -ge 2 ]
then
sudo nohup ../../runtime/samples/real_rpc_basic/server_main --runtime_id=12 --input_port_mac="52:54:01:02:00:01" \
--output_port_mac="52:54:01:02:00:02" --control_port_mac="52:54:01:02:00:03" --rpc_ip="202.45.128.154" --rpc_port=10242 \
--input_port="rt2_iport" --output_port="rt2_oport" --control_port="rt2_cport" --worker_core=2 > rt2_log.log 2>&1 &
fi

if [ "$1" -ge 3 ]
then
sudo nohup ../../runtime/samples/real_rpc_basic/server_main --runtime_id=13 --input_port_mac="52:54:01:03:00:01" \
--output_port_mac="52:54:01:03:00:02" --control_port_mac="52:54:01:03:00:03" --rpc_ip="202.45.128.154" --rpc_port=10243 \
--input_port="rt3_iport" --output_port="rt3_oport" --control_port="rt3_cport" --worker_core=3 > rt3_log.log 2>&1 &
fi

if [ "$1" -ge 4 ]
then
sudo nohup ../../runtime/samples/real_rpc_basic/server_main --runtime_id=14 --input_port_mac="52:54:01:04:00:01" \
--output_port_mac="52:54:01:04:00:02" --control_port_mac="52:54:01:04:00:03" --rpc_ip="202.45.128.154" --rpc_port=10244 \
--input_port="rt4_iport" --output_port="rt4_oport" --control_port="rt4_cport" --worker_core=13 > rt4_log.log 2>&1 &
fi


if [ "$1" -ge 5 ]
then
sudo nohup ../../runtime/samples/real_rpc_basic/server_main --runtime_id=15 --input_port_mac="52:54:01:05:00:01" \
--output_port_mac="52:54:01:05:00:02" --control_port_mac="52:54:01:05:00:03" --rpc_ip="202.45.128.154" --rpc_port=10245 \
--input_port="rt5_iport" --output_port="rt5_oport" --control_port="rt5_cport" --worker_core=14 > rt5_log.log 2>&1 &
fi

if [ "$1" -ge 6 ]
then
sudo nohup ../../runtime/samples/real_rpc_basic/server_main --runtime_id=16 --input_port_mac="52:54:01:06:00:01" \
--output_port_mac="52:54:01:06:00:02" --control_port_mac="52:54:01:06:00:03" --rpc_ip="202.45.128.154" --rpc_port=10246 \
--input_port="rt6_iport" --output_port="rt6_oport" --control_port="rt6_cport" --worker_core=15 > rt6_log.log 2>&1 &
fi
