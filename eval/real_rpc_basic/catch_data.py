import os
import sys
import string
import re
import time
import signal
import subprocess
import matplotlib.pyplot as pl
import numpy as np
import termios
def read_data():
  process=subprocess.Popen("sudo ../../deps/bess/bessctl/bessctl show module", stdout=subprocess.PIPE, shell=True)
  output, error=process.communicate()
  lines = output.split(os.linesep);
  begin=0
  end=0  
  for i in range(len(lines)):
    if  '0:sink0' in lines[i]:
      begin+=long(lines[i].split("packets")[1].split(" ")[1])

  time.sleep(1)
  process=subprocess.Popen("sudo ../../deps/bess/bessctl/bessctl show module", stdout=subprocess.PIPE, shell=True)
  output1, error1=process.communicate()
  lines1 = output1.split(os.linesep);  
  for i in range(len(lines1)):
    if  '0:sink0' in lines1[i]:
      end+=long(lines1[i].split("packets")[1].split(" ")[1])

  return (end-begin)

def press_anykey_exit(msg):
  fd=sys.stdin.fileno()
  old_ttyinfo=termios.tcgetattr(fd)
  new_ttyinfo=old_ttyinfo[:]
  new_ttyinfo[3]&=~termios.ICANON
  new_ttyinfo[3]&=~termios.ECHO
  sys.stdout.write(msg)
  sys.stdout.flush()
  termios.tcsetattr(fd,termios.TCSANOW, new_ttyinfo)
  os.read(fd,7)
  termios.tcsetattr(fd, termios.TCSANOW, old_ttyinfo)
def main():
  xlist=[]
  ylist=[]
  ylist2=[]
  for i in range(20):
    xlist.append(i*2)

  for i in range(20):
    time.sleep(2)
    packets=read_data()
    print(packets)
    ylist.append(packets)
  
  press_anykey_exit("press any key continue")
 

  for i in range(20):
    time.sleep(2)
    packets=read_data()
    print(packets)
    ylist2.append(packets)

  pl.figure(num=1,figsize=(8,6))
  pl.title('throughput with/without dynamic update',size=14)
  pl.xlabel("time(s)",size=14)
  pl.ylabel("throughput(pkt/s)",size=14)
  pl.plot(xlist,ylist,color='b',label="with dynamic_update")
  pl.plot(xlist,ylist2,color='r',label="without dynamic_update")
  pl.legend(loc="lower right")
  pl.savefig('figure.png',format='png')


if __name__ == '__main__':
    main()


