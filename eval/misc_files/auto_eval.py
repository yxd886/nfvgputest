#!/usr/bin/env python2.7
import random
import time

import grpc

import optparse


import sys
import subprocess
import signal
import time


#Initialize the arguments

def parse_arguments():
	parser = optparser.OptionParser()

	#test type def NORMAL/REPLICATION/MIGRATION
	parser.add_option('-t', '--test-type', action="store", type="string", dest="test_type", help="which type of test : THROUGHPUT/REPLICATION/MIGARTION", default="REPLICATION")

	options, args = parser.parse_args()

 	return options,args

def initialize_grpc():


def start_test(options):


	if options.test_type == "NORMAL":
		test_normal(options)
	elif options.test_type == "REPLICATION":
		test_replication(options)
    elif options.test_type == "MIGRATION":
    	test_migration(options)
    else


def test_normal(options):

	#traffic flow control
	incre_base = 100

	basic_concurrent_flow = 0	

	basic_concurrent_number = 0

	#worker and thread
	worker_num = 1
	thread_num = 1

	#network function type
	nf_type = 0

	#test status
	continue_test = true
	
	packet_loss = 0

	time_before, time_after = 0;

	#test result
	throughput = []

	while continue_test:		
		#grpc start normal

		#get packt loss

		if packet_loss>0 :

			#decrease flow

		#remotely clean test thread

		#sleep for 10 s

	#draw figure 	

def test_replication(options):

def test_migration(options):

	
class Usage(Exception):
	def _init_(seft, msg):
		self.msg = msg

def main(argv = None):
	if argv is None:
		argv = sys.argv


