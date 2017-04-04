#! /bin/sh

PWD=`pwd`


../../runtime/samples/nfa_rpc_client

#../../runtime/samples/replication_start

echo "Adding connections to portout"
sudo ../../deps/bess/bessctl/bessctl add connection fg1 rt1_iport_portout
if [ "$1" -ge "2" ]
then
sudo ../../deps/bess/bessctl/bessctl add connection fg2 rt2_iport_portout
fi

if [ "$1" -ge "3" ]
then
sudo ../../deps/bess/bessctl/bessctl add connection fg3 rt3_iport_portout
fi

if [ "$1" -ge "4" ]
then
sudo ../../deps/bess/bessctl/bessctl add connection fg4 rt4_iport_portout
fi

if [ "$1" -ge "5" ]
then
sudo ../../deps/bess/bessctl/bessctl add connection fg5 rt5_iport_portout
fi

if [ "$1" -ge "6" ]
then
sudo ../../deps/bess/bessctl/bessctl add connection fg6 rt6_iport_portout
fi
