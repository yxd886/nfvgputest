#ifndef D_CAF_NF_FLOW_MONITOR_HPP
#define D_CAF_NF_FLOW_MONITOR_HPP
#include <rte_config.h>
#include <rte_mbuf.h>
#include <netinet/ip.h>
#include <netinet/tcp.h>
#include <netinet/udp.h>
//#include <netinet/in.h>
#include <rte_ether.h>
#include <rte_ethdev.h>
#include <time.h>
#include <iostream>
#include <fstream>
#include <string>
#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <stdlib.h>
#include <vector>
#include <sys/time.h>
#include <deque>
#include <set>
#include <map>
#include <list>
#include <asm-generic/int-ll64.h>
#include "d_flow_monitor_fs.cuh"
#include "d_fm_headinfo.cuh"
#include "../d_base/d_nf_item.h"


#include <glog/logging.h>

class d_flow_monitor{
public:
	__device__ d_flow_monitor(){

  }
	__device__ ~d_flow_monitor(){

  }



	__device__ void nf_logic_impl(Pkt* pkt, d_flow_monitor_fs* fs){

		process(pkt, fs);
		//    printf("total number: %d\nudp number: %d\ntcp number: %d\nicmp number: %d\n",ptr->no_total,ptr->no_tcp,ptr->no_udp,ptr->no_icmp);

	}


__device__ void process(Pkt* raw_packet,d_flow_monitor_fs* fs){

  	if(fs->counter==0){

      //fs->CreatedTime=time(0);
      fs->SrcIp =1;
      fs->SrcIp = Ntohl(raw_packet->headinfo.m_pIphdr.saddr);
      fs->DstIp = Ntohl(raw_packet->headinfo.m_pIphdr.daddr);
      uint32_t tmp;

      tmp=raw_packet->headinfo.m_pIphdr.tot_len;
      tmp=raw_packet->headinfo.m_pIphdr.id;
      tmp=raw_packet->headinfo.m_pIphdr.frag_off;
      tmp=raw_packet->headinfo.m_pIphdr.ttl;
      tmp=raw_packet->headinfo.m_pIphdr.check;


      fs->protocol   = raw_packet->headinfo.m_pIphdr.protocol;
      if(raw_packet->headinfo.is_tcp==0){
			  fs->SrcPort=0;
			  fs->DstPort=0;
      }else{
      	fs->SrcPort = Ntohs(raw_packet->headinfo.m_pTcphdr.th_sport);
      	fs->DstPort = Ntohs(raw_packet->headinfo.m_pTcphdr.th_dport);

       }

  	}

  	//fs->RefreshTime=time(0);
    if(fs->protocol==IPPROTO_TCP){
    	fs->no_tcp++;

    }else if(fs->protocol==IPPROTO_UDP){
    	fs->no_udp++;

    }else if(fs->protocol==IPPROTO_ICMP){
    	fs->no_icmp++;

    }
    fs->no_total++;
    fs->counter++;
  }


};

#endif
