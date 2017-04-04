#! /bin/sh

sudo ../../deps/bess/bessctl/bessctl daemon reset

sudo ../../deps/bess/bessctl/bessctl run file bess_rt1_script

ssh net@202.45.128.155 "cd ~/nfa/eval/distributed_test && sudo ../../deps/bess/bessctl/bessctl daemon reset && sudo ../../deps/bess/bessctl/bessctl run file bess_rt2_script"

ssh net@202.45.128.156 "cd ~/nfa/eval/distributed_test && sudo ../../deps/bess/bessctl/bessctl daemon reset && sudo ../../deps/bess/bessctl/bessctl run file bess_rt3_script"
