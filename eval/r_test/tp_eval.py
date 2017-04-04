#!/usr/bin/env python2.7
import os
import optparse
import sys
import subprocess
import signal
import time
import paramiko
import re
cmd_stop = './stop.sh'
cmd_start = './start.sh'
FNULL = open(os.devnull, 'w')
def parse_arguments():
  parser = optparse.OptionParser()

  parser.add_option('', '--test-type',
                    action="store",
                    type="string",
                    dest="test_type",
                    help="which type of test : THROUGHPUT/REPLICATION/MIGARTION",
                    default="THROUGHPUT")

  parser.add_option('', '--sc', action="store", type="string", dest="service_chain", help="chain rule", default="pkt_counter")

  parser.add_option('', '--r1', action="store", type="int", dest="r1_number", help="How many rts in r1", default="1")

  parser.add_option('', '--r2', action="store", type="int", dest="r2_number", help="How many rts in r2", default="1")

  parser.add_option('', '--r3', action="store", type="int", dest="r3_number", help="How many rts in r3", default="1")

  options, args = parser.parse_args()

  return options,args

def local_start_up_ok(num_of_rts):
  success_flag = False;

  for x in range(1,num_of_rts+1):

    cmd="cat ./rt"+str(x)+"_log.log"
    process = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True, preexec_fn=os.setsid)
    success_flag = False

    for line in iter(process.stdout.readline, ''):
      if len(line.split(']'))>1 and line.split(']')[1] == ' Prepare server\n':
        success_flag = True
        break;

    if success_flag == False:
      break;

  if success_flag == False:
    print "[ERROR] Fail to start the runtime correctly, need to retry."
  else:
    print "Successfully start all the runtimes."

  return success_flag

def remote_start_up_ok(ssh, num_of_rts):
  success_flag = False;

  for x in range(1, num_of_rts+1):

    cmd="cat /home/net/nfa/eval/r_test/rt"+str(x)+"_log.log"
    print cmd
    stdin,stdout,stderr =  ssh.exec_command(cmd)
    success_flag = False

    for line in stdout:
      print line
      if line.find("Prepare server")!=-1:
        success_flag = True
        break;

    if success_flag == False:
      break;

  if success_flag == False:
    print "[ERROR] Fail to start the runtime correctly, need to retry."
  else:
    print "Successfully start all the runtimes."

  return success_flag


def start_r1(options):

  loop = True

  while (loop):
    cmd="sudo ./clean_rt.sh"
    process = subprocess.Popen(cmd, stdout=FNULL, shell=True)
    output, error = process.communicate()


    time.sleep(1)
    cmd="sudo ./start_r1.sh 6"
    process = subprocess.Popen(cmd, stdout=FNULL, shell=True)
    output, error = process.communicate()

    time.sleep(2)
    loop = not local_start_up_ok(6)

  print "R1 (Virutal Switch) Configuration Finished"

def start_r2(ssh, options):
  loop = True
  success_flag = False;
  while(loop):
    cmd="sudo ~/nfa/eval/r_test/clean_rt.sh"
    stdin,stdout,stderr =  ssh.exec_command(cmd);
    time.sleep(1)

    cmd="cd ~/nfa/eval/r_test && sudo ./start_r2.sh " + str(options.r2_number) +" "+ str(options.service_chain)
    stdin,stdout,stderr =  ssh.exec_command(cmd);
    time.sleep(2)

    success_flag = True;
    for x in range(1, options.r2_number+1):
      cmd="cat /home/net/nfa/eval/r_test/rt"+str(x)+"_log.log"
      stdin,stdout,stderr =  ssh.exec_command(cmd)
      success_flag = False

      for line in stdout:
        if line.find("Prepare server")!=-1:
          success_flag = True
          break;

      if success_flag == False:
        break;

    if success_flag == False:
      print "[ERROR] Fail to start the runtime correctly, need to retry."
    else:
      print "Successfully start all the runtimes on r2."
    loop = not success_flag

  print "R2 (rt1, rt2, rt3) Configuration Finished"

def start_r3(ssh, options):
  loop = True
  success_flag = False;
  while(loop):
    cmd="sudo ~/nfa/eval/r_test/clean_rt.sh"
    stdin,stdout,stderr =  ssh.exec_command(cmd);
    time.sleep(1)

    cmd="cd ~/nfa/eval/r_test && sudo ./start_r3.sh " + str(options.r3_number) +" "+ str(options.service_chain)
    stdin,stdout,stderr =  ssh.exec_command(cmd);
    time.sleep(2)

    success_flag = True;
    for x in range(1, options.r3_number+1):
      cmd="cat /home/net/nfa/eval/r_test/rt"+str(x)+"_log.log"
      stdin,stdout,stderr =  ssh.exec_command(cmd)
      success_flag = False

      for line in stdout:
        if line.find("Prepare server")!=-1:
          success_flag = True
          break;

      if success_flag == False:
        break;

    if success_flag == False:
      print "[ERROR] Fail to start the runtime correctly, need to retry."
    else:
      print "Successfully start all the runtimes on r3."
    loop = not success_flag

  print "R3 (rt1, rt2, rt3) Configuration Finished"

def start_traffic_gen(options):
  cmd="sudo ./start_flowgen.sh "+str(options.r1_number)
  #process = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True)
  process = subprocess.Popen(cmd, stdout=FNULL, shell=True)
  output, error = process.communicate()

def read_pkts(ssh,rt_num):
  cmd="sudo ~/nfa/deps/bess/bessctl/bessctl show port rt"+str(rt_num)+"_iport"
  stdin,stdout,stderr = ssh.exec_command(cmd);

  received_pkts_line = ''
  dropped_pkts_line = ''

  i = 0
  for line in stdout:
    if i == 6:
	received_pkts_line = line
    if i == 7:
        dropped_pkts_line = line
    i=i+1


  return long(received_pkts_line.split(":")[1].replace(',', '')), long(dropped_pkts_line.split(":")[1].replace(',', ''))


def test():
  options,args = parse_arguments()
  print "Start Test with the following options:"
  print options

  #print "Creating SSH to R2 & R3"

  ssh_r2 = paramiko.SSHClient()
  ssh_r2.set_missing_host_key_policy(paramiko.AutoAddPolicy())
  ssh_r2.connect('202.45.128.155',username='net',password='netexplo')
  ssh_r2.exec_command('cd ~/nfa/eval/r_test')

  ssh_r3 = paramiko.SSHClient()
  ssh_r3.set_missing_host_key_policy(paramiko.AutoAddPolicy())
  ssh_r3.connect('202.45.128.156',username='net',password='netexplo')
  ssh_r3.exec_command('cd ~/nfa/eval/r_test')

  print "Start runtimes..."
  start_r1(options)
  start_r2(ssh_r2, options)
  start_r3(ssh_r3, options)

  print "Start Traffic Generation"

  start_traffic_gen(options)

  print "Wait for 3 seconds to get traffic ramp up..."

  time.sleep(3)

  recovery_time = "";
  migration_time = "";
  before_received = 0;
  before_dropped = 0;
  after_received = 0;
  after_dropped = 0;
  before_time = 0;
  after_time = 0;

#  if options.test_type == "THROUGHPUT":
  print "Start Testing Throughput"

  tmp1,tmp2 = read_pkts(ssh_r2,1)
  before_received +=tmp1;
  before_dropped +=tmp2;

  tmp1,tmp2 = read_pkts(ssh_r2,2)
  before_received +=tmp1;
  before_dropped +=tmp2;

  tmp1,tmp2 = read_pkts(ssh_r2,3)
  before_received +=tmp1;
  before_dropped +=tmp2;

  tmp1,tmp2 = read_pkts(ssh_r3,1)
  before_received +=tmp1;
  before_dropped +=tmp2;

  tmp1,tmp2 = read_pkts(ssh_r3,2)
  before_received +=tmp1;
  before_dropped +=tmp2;

  tmp1,tmp2 = read_pkts(ssh_r3,3)
  before_received +=tmp1;
  before_dropped +=tmp2;


  before_time = time.time() * 1000

  time.sleep(3)

  tmp1,tmp2 = read_pkts(ssh_r2,1)
  after_received +=tmp1;
  after_dropped +=tmp2;

  tmp1,tmp2 = read_pkts(ssh_r2,2)
  after_received +=tmp1;
  after_dropped +=tmp2;

  tmp1,tmp2 = read_pkts(ssh_r2,3)
  after_received +=tmp1;
  after_dropped +=tmp2;

  tmp1,tmp2 = read_pkts(ssh_r3,1)
  after_received +=tmp1;
  after_dropped +=tmp2;

  tmp1,tmp2 = read_pkts(ssh_r3,2)
  after_received +=tmp1;
  after_dropped +=tmp2;

  tmp1,tmp2 = read_pkts(ssh_r3,3)
  after_received +=tmp1;
  after_dropped +=tmp2;

  after_time = time.time() * 1000

  print "Stop testing..."
  ssh_r2.close()
  ssh_r3.close()
  #stop_traffic_gen(options)
  time.sleep(1)
  return after_received-before_received, after_dropped-before_dropped, after_time-before_time





def main():


  packet_out, packet_dropped, duration_time = test()
  print '[RESULT] ' + str(packet_out) + ' '+str(packet_dropped)+' '+str(duration_time)

if __name__ == '__main__':
    main()
