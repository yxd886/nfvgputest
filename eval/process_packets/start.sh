#! /bin/sh

PWD=`pwd`

value=`cat ./flowgen_arg`

sudo ../../deps/bess/bessctl/bessctl $value
sudo ../../deps/bess/bessctl/bessctl add module Sink s

sudo ../../deps/bess/bessctl/bessctl add port ZeroCopyVPort pi
sudo ../../deps/bess/bessctl/bessctl add module PortOut pi_out "{'port':'pi'}"

sudo ../../deps/bess/bessctl/bessctl add port ZeroCopyVPort po
sudo ../../deps/bess/bessctl/bessctl add module PortInc po_inc "{'port':'po'}"

sudo ../../deps/bess/bessctl/bessctl add connection fg pi_out
sudo ../../deps/bess/bessctl/bessctl add connection po_inc s

sudo ../../runtime/samples/process_packets --input_port="pi" --output_port="po"
