#!/usr/bin/env python2.7
import os
import optparse
import sys
import subprocess
import signal
import time

import grpc

import nfa_msg_pb2
import nfa_msg_pb2_grpc

cmd_stop = './stop.sh'
cmd_start = './start.sh'

def parse_arguments():
  parser = optparse.OptionParser()

  parser.add_option('', '--test-type',
                    action="store",
                    type="string",
                    dest="test_type",
                    help="which type of test : THROUGHPUT/REPLICATION/MIGARTION",
                    default="THROUGHPUT")

  #parser.add_option()
  options, args = parser.parse_args()

  return options,args

def start_master(options, stub):

  res = stub.LivenessCheck(nfa_msg_pb2.LivenessRequest())

  if res is None :
    print("Runtime dead.")  
  print( "Runtime alive.")

  ClientStatus = stub.GetRuntimeState(nfa_msg_pb2.GetRuntimeStateReq())
 
  print ClientStatus.port_state.input_port_outgoing_pkts
  print "Runtime ID: "+str(ClientStatus.local_runtime.runtime_id)
  #print "Sleep 3 seconds for initialization..."
  #time.sleep(3)
  #print "Worker initializtion finishes."
  return ClientStatus

def read_port_pkts(stub):
  res = stub.GetRuntimeState(nfa_msg_pb2.GetRuntimeStateReq())
  return res.port_state.output_port_outgoing_pkts,res.port_state.output_port_dropped_pkts

def read_pkts():
  cmd="~/bess/bessctl/bessctl show port"
  process = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True)
  output, error = process.communicate()

  #find viw_2
  received_pkts_line = ""
  dropped_pkts_line = ""
  lines = output.split(os.linesep);

  for i in range(len(lines)):
    if 'pi' in lines[i]:
      received_pkts_line = lines[i+6]
  cmd="../bess/bessctl/bessctl show port"
  process = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True)
  output, error = process.communicate()

  #find viw_2
  received_pkts_line = ""
  dropped_pkts_line = ""
  lines = output.split(os.linesep);

  for i in range(len(lines)):
    if 'pi' in lines[i]:
      received_pkts_line = lines[i+6]
      dropped_pkts_line = lines[i+7]
      break

  return long(received_pkts_line.split(":")[1].replace(',', '')), long(dropped_pkts_line.split(":")[1].replace(',', ''))


def test(stub):
  options,args = parse_arguments()
  print "Start Test with the following options:"
  print options

  print "Start the master process."
  master_process = start_master(options, stub)

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

  before_received,before_dropped = read_port_pkts(stub)
  before_time = time.time() * 1000

  time.sleep(10)

  after_received, after_dropped = read_port_pkts(stub)
  after_time = time.time() * 1000

  print "Stop testing"
  #stop_traffic_gen(options)
  time.sleep(1)
  #process_stop = subprocess.Popen(cmd_stop, stdout=subprocess.PIPE, shell=True, preexec_fn=os.setsid)
 # os.killpg(os.getpgid(master_process.pid), signal.SIGTERM)

  #logto_output_file(options, after_received-before_received, after_dropped-before_dropped, after_dropped-before_dropped, recovery_time, migration_time)
  return after_received-before_received, after_dropped-before_dropped, after_time-before_time

def start_grpc(addr):

  channel = grpc.insecure_channel(addr)
  
  return channel

  #stub = nfa_grpc.GreeterStub(channel)
  response = stub.SayHello(helloworld_pb2.HelloRequest(name='you'))
  #print("Greeter client received: " + response.message)

def main():

  channel1 = start_grpc('localhost:10240')
  stub1 = nfa_msg_pb2_grpc.Runtime_RPCStub(channel1)

  packet_out, packet_dropped, duration_time = test(stub1)
  print str(packet_out)+' '+str(packet_dropped)+' '+str(duration_time)

if __name__ == '__main__':
    main()
  
