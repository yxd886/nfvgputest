#! /bin/sh

git pull

make -C ../../runtime -j8

ssh net@202.45.128.155 "cd ~/nfa && git pull && make -C ./runtime"

ssh net@202.45.128.156 "cd ~/nfa && git pull && make -C ./runtime"
