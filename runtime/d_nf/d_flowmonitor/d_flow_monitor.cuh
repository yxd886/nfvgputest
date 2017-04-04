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



	__device__ void nf_logic_impl(char* pkt, d_flow_monitor_fs* fs){

		process(pkt, fs);
		//    printf("total number: %d\nudp number: %d\ntcp number: %d\nicmp number: %d\n",ptr->no_total,ptr->no_tcp,ptr->no_udp,ptr->no_icmp);

	}


__device__ void process(char* raw_packet,d_flow_monitor_fs* fs){

  	if(fs->counter==0){
  		struct d_head_info t;
      struct d_head_info* hd=&t;
      Format(raw_packet,hd);
      //fs->CreatedTime=time(0);
      fs->SrcIp = Ntohl(hd->m_pIphdr->saddr);
      fs->DstIp = Ntohl(hd->m_pIphdr->daddr);
      fs->protocol   = hd->m_pIphdr->protocol;
      if(hd->m_pTcphdr==NULL){
			  fs->SrcPort=0;
			  fs->DstPort=0;
      }else{
      	fs->SrcPort = Ntohs(hd->m_pTcphdr->source);
      	fs->DstPort = Ntohs(hd->m_pTcphdr->dest);

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

    __device__ void Format(char* packet,struct d_head_info* hd){
    hd->m_pEthhdr = (struct ether_hdr*)packet;
    hd->m_pIphdr = (struct iphdr*)(packet + sizeof(struct ether_hdr));
    hd->m_pTcphdr = (struct tcphdr*)(packet + sizeof(struct ether_hdr)+(hd->m_pIphdr->ihl)*4);
    hd->protocol =  hd->m_pIphdr->protocol;
    return;
  }


};

#endif
