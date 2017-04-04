#! /bin/sh

ulimit -Hn 70000
ulimit -Sn 70000
./tp_eval.py --r1=6 --r2=1 --r3=0 --sc=flow_monitor
./tp_eval.py --r1=6 --r2=1 --r3=1 --sc=flow_monitor
./tp_eval.py --r1=6 --r2=2 --r3=1 --sc=flow_monitor
./tp_eval.py --r1=6 --r2=2 --r3=2 --sc=flow_monitor
./tp_eval.py --r1=6 --r2=3 --r3=2 --sc=flow_monitor
./tp_eval.py --r1=6 --r2=3 --r3=3 --sc=flow_monitor

./tp_eval.py --r1=6 --r2=1 --r3=0 --sc=http_parser
./tp_eval.py --r1=6 --r2=1 --r3=1 --sc=http_parser
./tp_eval.py --r1=6 --r2=2 --r3=1 --sc=http_parser
./tp_eval.py --r1=6 --r2=2 --r3=2 --sc=http_parser
./tp_eval.py --r1=6 --r2=3 --r3=2 --sc=http_parser
./tp_eval.py --r1=6 --r2=3 --r3=3 --sc=http_parser

./tp_eval.py --r1=6 --r2=1 --r3=0 --sc=firewall
./tp_eval.py --r1=6 --r2=1 --r3=1 --sc=firewall
./tp_eval.py --r1=6 --r2=2 --r3=1 --sc=firewall
./tp_eval.py --r1=6 --r2=2 --r3=2 --sc=firewall
./tp_eval.py --r1=6 --r2=3 --r3=2 --sc=firewall
./tp_eval.py --r1=6 --r2=3 --r3=3 --sc=firewall


