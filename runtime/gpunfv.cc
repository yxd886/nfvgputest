
/**
 * Copyright 1993-2012 NVIDIA Corporation.  All rights reserved.
 *
 * Please refer to the NVIDIA end user license agreement (EULA) associated
 * with this source code for terms and conditions that govern your use of
 * this software. Any use, reproduction, disclosure, or distribution of
 * this software and related documentation outside the terms of the EULA
 * is strictly prohibited.
 */
#include <stdio.h>
#include <stdlib.h>

#include <netinet/ip.h>
#include <netinet/tcp.h>
#include <netinet/udp.h>
#include <netinet/in.h>
//#include <net/ethernet.h>
#include <time.h>
#include   <sys/time.h>

#include <cuda_runtime.h>

#include <helper_cuda.h>

#include "d_nf/d_base/d_nf_processor.cuh"
#include "d_nf/d_base/Pkt.h"
#include "d_nf/d_pktcounter/d_pkt_counter.cuh"


/**
 * This macro checks return value of the CUDA runtime call and exits
 * the application if the call failed.
 *
 * See cuda.h for error code descriptions.
 */


void Format(char* packet,struct d_headinfo* hd){
  struct ether_hdr* m_pEthhdr;
  struct iphdr* m_pIphdr;
  struct tcphdr* m_pTcphdr;
  struct udphdr* m_pUdphdr;



  m_pEthhdr = (struct ether_hdr*)packet;
  memcpy(&(hd->m_pEthhdr),m_pEthhdr,sizeof(struct ether_hdr));
  m_pIphdr = (struct iphdr*)(packet + sizeof(struct ether_hdr));
  memcpy(&(hd->m_pIphdr),m_pIphdr,sizeof(struct iphdr));
  if(m_pIphdr->protocol==IPPROTO_TCP){
         m_pTcphdr = (struct tcphdr*)(packet + sizeof(struct ether_hdr)+(hd->m_pIphdr.ihl)*4);
         memcpy(&(hd->m_pTcphdr),m_pTcphdr,sizeof(struct tcphdr));
         hd->is_udp=0;
  }else if(m_pIphdr->protocol==IPPROTO_UDP){
     hd->is_tcp = 0;
     m_pUdphdr=(struct udphdr*)(packet + sizeof(struct ether_hdr)+(hd->m_pIphdr.ihl)*4);
     memcpy(&(hd->m_pUdphdr),m_pUdphdr,sizeof(struct udphdr));

   }else{
      hd->is_tcp = 0;
      hd->is_udp = 0;
    }

  hd->protocol =  m_pIphdr->protocol;
  return;
}


void Pkt_insert(struct Pkt* Pkts,char* pkt,int i,int total_len){

	char* dst=Pkts[i].pkt;
	memcpy(dst,pkt,total_len);
	Format(pkt,&(Pkts[i].headinfo));
	Pkts[i].empty=0;

}

void Pkt_reset(struct Pkt* Pkts,int num){

	for(int i=0;i<num;i++){
		Pkts[i].empty=1;
	}
}

void test(){

	printf("sizeof bool: %d",sizeof(bool));
	printf("sizeof PKT: %d",sizeof(Pkt));
	printf("sizeof FS: %d",sizeof(Fs));
	printf("sizeof iphdr: %d",sizeof(iphdr));
	struct ether_hdr *m_pEthhdr;
	struct iphdr *m_pIphdr;
    char tmp1[2000];
    memset(tmp1,0,sizeof(tmp1));
    char *head=tmp1;
    char *packet=tmp1+34;
    uint16_t len;

	Pkt *pkts=NULL;
	Fs *fs=NULL;

	cudaError_t err = cudaSuccess;

	err=cudaMallocManaged(&pkts, 32*32*sizeof(Pkt));
	if(err!=cudaSuccess){
			printf("cuda malloc fail，error code: %s\n",cudaGetErrorString(err));
	}
	err=cudaMallocManaged(&fs, 32*sizeof(Fs));
	if(err!=cudaSuccess){
			printf("cuda malloc fail，error code: %s\n",cudaGetErrorString(err));
	}

	Pkt_reset((Pkt*)pkts,32*32);
	int counter=0;
	for(int i=0;i<32;i++){
        d_pkt_counter_fs* tmp_ptr=reinterpret_cast<d_pkt_counter_fs*>(fs[i].fs[1]);
        printf("packet num: %d\n",tmp_ptr->counter);
        counter+=tmp_ptr->counter;
    }

    FILE* f;
    if( (f=fopen("code.txt","r"))==NULL){
 	  printf("OPen File failure\n");
 	}
    //printf("begin to enter loop\n");
    int i=0;

    //printf("begin to enter loop1\n");

    struct timeval whole_begin;
    gettimeofday(&whole_begin,0);

    for(int j=0;j<300;j++){
       fread(head,34,1,f);
 	  m_pEthhdr=(struct ether_hdr *)head;
 	  m_pIphdr=(struct iphdr *)(head+sizeof(struct ether_hdr));
 	   len = ntohs(m_pIphdr->tot_len);
 	   fread(packet,len-20,1,f);
 	   if(i>=0){

 		Pkt_insert(pkts,head,i,len+14);
 		gpu_nf_process(pkts,fs,0x01,32);
 		Pkt_reset((Pkt*)pkts,32*32);
 		i=0;

 	   }else{
		Pkt_insert(pkts,head,i,len+14);

		i++;

 	   }

   }
    counter=0;
    for(int i=0;i<32;i++){
        d_pkt_counter_fs* tmp_ptr=reinterpret_cast<d_pkt_counter_fs*>(fs[i].fs[1]);
        printf("packet num: %d\n",tmp_ptr->counter);
        counter+=tmp_ptr->counter;
    }
    printf("total packet num: %d\n",counter);
	cudaFree(pkts);
	cudaFree(fs);

    struct timeval whole_end;
    gettimeofday(&whole_end,0);
    long begin=whole_begin.tv_sec*1000000 + whole_begin.tv_usec;
    long end=whole_end.tv_sec*1000000 + whole_end.tv_usec;
   printf("time: %ld\n,",end-begin);

   fclose(f);
}

int main(int argc, char **argv)
{


	test();

	return 0;
}

