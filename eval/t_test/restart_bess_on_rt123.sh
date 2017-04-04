#! /bin/sh

sudo ../../deps/bess/bessctl/bessctl daemon reset

sudo ../../deps/bess/bessctl/bessctl run file bess_r1_script

ssh net@202.45.128.155 "cd ~/nfa/eval/t_test && sudo ../../deps/bess/bessctl/bessctl daemon reset && sudo ../../deps/bess/bessctl/bessctl run file bess_r2_script"

ssh net@202.45.128.156 "cd ~/nfa/eval/t_test && sudo ../../deps/bess/bessctl/bessctl daemon reset && sudo ../../deps/bess/bessctl/bessctl run file bess_r3_script"
