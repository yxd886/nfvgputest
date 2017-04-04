#ifndef D_MODIFIED_FIREWALL_HPP
#define D_MODIFIED_FIREWALL_HPP
#include <netinet/ip.h>
#include <netinet/tcp.h>
#include <netinet/udp.h>
#include <netinet/in.h>
//#include <rte_ethdev.h>
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
#include <rte_config.h>
#include <rte_memory.h>
#include <rte_memzone.h>
#include <rte_launch.h>
#include <rte_eal.h>
#include <rte_per_lcore.h>
#include <rte_lcore.h>
#include <rte_debug.h>
#include <rte_common.h>
#include <rte_log.h>
#include <rte_malloc.h>
#include <rte_memory.h>
#include <rte_memcpy.h>
#include <rte_memzone.h>
#include <rte_eal.h>
#include <rte_per_lcore.h>
#include <rte_launch.h>
#include <rte_atomic.h>
#include <rte_cycles.h>
#include <rte_prefetch.h>
#include <rte_lcore.h>
#include <rte_per_lcore.h>
#include <rte_branch_prediction.h>
#include <rte_interrupts.h>
#include <rte_pci.h>
#include <rte_random.h>
#include <rte_debug.h>
#include <rte_ether.h>
#include <rte_ethdev.h>
#include <rte_ring.h>
#include <rte_mempool.h>
#include <rte_mbuf.h>

#include "d_fw_headinfo.cuh"
//#include "../../bessport/packet.h"
#include "d_firewall_fs.cuh"
#include "../d_base/d_nf_item.h"
#include <cassert>


class Rules{
public: 
	__device__ Rules(){counter=0;}
	__device__ ~Rules(){}
	__device__ int get_number(){
		return counter;
	}
	__device__ struct d_rule* get_element(int i){
		return d_rules[i];
	}
	__device__ void push_back(struct d_rule* rule_ptr){
		d_rules[counter]=rule_ptr;
		counter++;
	}
private:
	int counter;
	struct d_rule* d_rules[10];

};

class d_firewall{
public:
	__device__ d_firewall(){
   
    char saddr[200];
    memset(saddr,0,sizeof(saddr));
    char daddr[200];
    memset(daddr,0,sizeof(daddr));
    
    struct d_rule r;
    struct d_rule* rp=&r;
  //  std::cout<<"begin to read rules"<<std::endl;
   
      *(unsigned char *)&rp->saddr.addr=0;
      *(((unsigned char *)&rp->saddr.addr)+1)=0;
      *(((unsigned char *)&rp->saddr.addr)+2)=0;
      *(((unsigned char *)&rp->saddr.addr)+3)=0;
      rp->saddr.mask=32;
      rp->sport=65535;
      *((unsigned char *)&rp->daddr.addr)=0;
      *((unsigned char *)&rp->daddr.addr+1)=0;
      *((unsigned char *)&rp->daddr.addr+2)=0;
      *((unsigned char *)&rp->daddr.addr+3)=0;
      rp->daddr.mask=32;
      rp->dport=65535;
      rp->protocol=6;
      rp->action=0;
     rules.push_back(&r);
      
      
      *(unsigned char *)&rp->saddr.addr=0;
      *(((unsigned char *)&rp->saddr.addr)+1)=0;
      *(((unsigned char *)&rp->saddr.addr)+2)=0;
      *(((unsigned char *)&rp->saddr.addr)+3)=0;
      rp->saddr.mask=32;
      rp->sport=65535;
      *((unsigned char *)&rp->daddr.addr)=119;
      *((unsigned char *)&rp->daddr.addr+1)=75;
      *((unsigned char *)&rp->daddr.addr+2)=217;
      *((unsigned char *)&rp->daddr.addr+3)=109;
      rp->daddr.mask=32;
      rp->dport=65535;
      rp->protocol=6;
      rp->action=1;
     rules.push_back(&r);
   
 //  std::cout<<"begin to close the rule file !"<<std::endl;
  
 //  std::cout<<"close the rule file successfully !"<<std::endl;
  }

	__device__ void nf_logic_impl(char* pkt, d_firewall_fs* fs);

private:

	__device__ void process(char* packet,d_firewall_fs* fs);

	__device__ void Format(char* packet,struct d_headinfo* hd);

	__device__ Bool CompareID_with_mask(uint32_t addr1, uint32_t addr2, uint8_t mask);

	__device__ void filter_local_out(struct d_headinfo *hd,d_firewall_fs* sesptr);

	__device__ uint16_t GetPort(struct d_headinfo *hd, int flag);



 Rules rules;

};



__device__ void d_firewall::nf_logic_impl(char* pkt, d_firewall_fs* fs){

	process(pkt,fs);
}



__device__ void d_firewall::process(char* packet,d_firewall_fs* fs){
struct d_headinfo t;
  struct d_headinfo* hd=&t;
  Format(packet,hd);
  filter_local_out(hd,fs);
}



__device__ void d_firewall::Format(char* packet,struct d_headinfo* hd){
  hd->m_pEthhdr = (struct ether_hdr*)packet;
  hd->m_pIphdr = (struct iphdr*)(packet + sizeof(struct ether_hdr));
  if(hd->m_pIphdr->protocol==IPPROTO_TCP){
         hd->m_pTcphdr = (struct tcphdr*)(packet + sizeof(struct ether_hdr)+(hd->m_pIphdr->ihl)*4);
         hd->m_pUdphdr=NULL;
  }else if(hd->m_pIphdr->protocol==IPPROTO_UDP){
     hd->m_pTcphdr = NULL;
     hd->m_pUdphdr=(struct udphdr*)(packet + sizeof(struct ether_hdr)+(hd->m_pIphdr->ihl)*4);
   }else{
      hd->m_pTcphdr = NULL;
      hd->m_pUdphdr=NULL;
    }

  hd->protocol =  hd->m_pIphdr->protocol;
  return;
}



__device__ Bool d_firewall::CompareID_with_mask(uint32_t addr1, uint32_t addr2, uint8_t mask){
  uint32_t addr1_temp, addr2_temp;
  Bool flag = false;
  addr1_temp = Ntohl(addr1);
  addr2_temp = Ntohl(addr2);

  addr1_temp = MASK_IP(addr1_temp, mask);
  addr2_temp = MASK_IP(addr2_temp, mask);

  flag = (addr1_temp == addr2_temp);


  return flag;
}



__device__ void d_firewall::filter_local_out(struct d_headinfo *hd,d_firewall_fs* sesptr){
  uint32_t s_addr, d_addr;
  uint8_t protocol;
  uint16_t s_port, d_port;
  Bool match = false;
  Bool flag = false;
  protocol = hd->protocol;
  s_addr = hd->m_pIphdr->saddr;
  d_addr = hd->m_pIphdr->daddr;
   sesptr->counter++;
  s_port = GetPort(hd, SRC);
  d_port = GetPort(hd, DEST);
  struct d_rule* ptr;
  for(int i=0;i<rules.get_number();i++){
	ptr=rules.get_element(i);
    match = false;
    match = (ptr->saddr.addr == ANY_ADDR ? true : CompareID_with_mask(ptr->saddr.addr,s_addr,ptr->saddr.mask));
    if(!match){

      continue;
    }
    match = (ptr->daddr.addr == ANY_ADDR ? true : CompareID_with_mask(ptr->daddr.addr,d_addr,ptr->daddr.mask));
    if(!match){
      continue;
    }
    match = (ptr->protocol == ANY_PROTOCOL) ? true : (ptr->protocol == protocol);
    if(!match){
      continue;
    }
    match = (ptr->sport == ANY_PORT) ? true : (ptr->sport == s_port);
    if(!match){
      continue;
    }
    match = (ptr->dport == ANY_PORT) ? true : (ptr->dport == d_port);
    if(!match){
      continue;
    }
  //  match = ptr->action ? 0 : 1;

    if(match){
      flag = ptr->action?false:true;
      ++sesptr->match_no;
      break;
    }
    else{
      flag = false;
      break;
    }
  }//loop for match rule
  if(flag){
    sesptr->drop_no++;
    sesptr->current_pass=false;
  }else{
    sesptr->pass_no++;
    sesptr->current_pass=true;
   }

}


__device__ uint16_t d_firewall::GetPort(struct d_headinfo *hd, int flag){
	uint16_t port = ANY_PORT;
	switch(hd->m_pIphdr->protocol){
		case IPPROTO_TCP:
			if(flag == SRC)
				port = Ntohs(hd->m_pTcphdr->source);
			else if(flag == DEST)
				port = Ntohs(hd->m_pTcphdr->dest);
			break;
		case IPPROTO_UDP:
			if(flag == SRC)
				port = Ntohs(hd->m_pUdphdr->source);
			else if(flag == DEST)
				port = Ntohs(hd->m_pUdphdr->dest);
			break;
		default:
			port = ANY_PORT;
	}
	return port;
 }


#endif
