#!/usr/bin/env python2.7
import os
import optparse
import sys
import subprocess
import signal
import time
import paramiko
import re


#I0122 18:07:42.905982 82940 coordinator_mp.cc:114] Successful migration : 500
#I0122 18:07:42.905987 82940 coordinator_mp.cc:115] Failed migration : 0
#I0122 18:07:42.905990 82940 coordinator_mp.cc:116] Null migration : 49500

def parse_arguments():
  parser = optparse.OptionParser()

  parser.add_option('', '--r2', action="store", type="int", dest="r2_number", help="How many rts in r2", default="1")

  parser.add_option('', '--r3', action="store", type="int", dest="r3_number", help="How many rts in r3", default="1")

  parser.add_option('', '--flow', action="store", type="int", dest="flow_number", help="Flows to migrate", default="50000")

  options, args = parser.parse_args()

  return options,args

def start_migration():
  cmd="sudo ~/nfa/runtime/samples/migration/m_start"
  process = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True)
  output, error = process.communicate()
  print "Migration started and wait 5 seconds"
  time.sleep(5)


def detect_result(options, ssh, runtime):
  #for x in range(1, options.r3_number+1):
  cmd="cat /home/net/nfa/eval/r_test/rt"+str(runtime)+"_log.log"
  stdin,stdout,stderr =  ssh.exec_command(cmd)
  success_flag = False
  time_result = ""
  flow_result = ""
  number = ""
  for line in stdout:
    if line.find("Successful migration")!=-1:
      number = line[line.find("Successful migration"):]
      success_flag = True
    if line.find("Migration takes") > 0:
      time_result = line[line.find("Migration takes")+16:-2]
  time.sleep(1)
  return str(success_flag)+" "+str(number)+" "+str(time_result)

def test_migration():
  options,args = parse_arguments()

  ssh_r2 = paramiko.SSHClient()
  ssh_r2.set_missing_host_key_policy(paramiko.AutoAddPolicy())
  ssh_r2.connect('202.45.128.155',username='net',password='netexplo')
  ssh_r2.exec_command('cd ~/nfa/eval/r_test')

  ssh_r3 = paramiko.SSHClient()
  ssh_r3.set_missing_host_key_policy(paramiko.AutoAddPolicy())
  ssh_r3.connect('202.45.128.156',username='net',password='netexplo')
  ssh_r3.exec_command('cd ~/nfa/eval/r_test')

  start_migration()
  
  print "r2 rt1 migration - "+str(detect_result(options, ssh_r2, 1))
  print "r2 rt2 migration - "+str(detect_result(options, ssh_r2, 2))
  print "r2 rt3 migration - "+str(detect_result(options, ssh_r2, 3))
  print "r3 rt1 migration - "+str(detect_result(options, ssh_r2, 1))
  print "r3 rt2 migration - "+str(detect_result(options, ssh_r2, 2))
  print "r3 rt3 migration - "+str(detect_result(options, ssh_r2, 3))


def main():

  test_migration()

if __name__ == "__main__" :
  main()
