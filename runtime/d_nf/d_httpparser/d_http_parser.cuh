
#ifndef D_CAF_NF_HTTP_PARSER_HPP
#define D_CAF_NF_HTTP_PARSER_HPP

#include "d_Public.cuh"
#include "d_Receiver.cuh"
#include "d_SessionHash.cuh"
#include <netinet/ip6.h>
#include "d_SessionHash.cuh"
//#include "../../bessport/packet.h"

#include <glog/logging.h>

class d_http_parser{
public:
	__device__  d_http_parser(){
    rcv = d_Receiver();
  }

	__device__ void nf_logic_impl(Pkt* pkt,d_http_parser_fs* fs){

		process(pkt,fs);

  }


private:

	__device__ void process(Pkt* raw_packet,d_http_parser_fs* fs){


	  rcv.Work(raw_packet,fs);

  }


  d_Receiver  rcv;
};


#endif
