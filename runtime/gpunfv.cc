
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
#include <net/ethernet.h>


#include <cuda.h>
#include "d_nf/d_base/d_nf_processor.cuh"
#include "d_nf/d_base/Pkt.h"


/**
 * This macro checks return value of the CUDA runtime call and exits
 * the application if the call failed.
 *
 * See cuda.h for error code descriptions.
 */
void Pkt_insert(struct Pkt* Pkts,char* pkt,int i,int total_len){

	while(Pkts[i].empty!=true){
		i+=1;
	}
	char* dst=Pkts[i].pkt;
	memcpy(dst,pkt,total_len);
	Pkts[i].empty=false;

}

void Pkt_reset(struct Pkt* Pkts,int num){

	for(int i=0;i<num;i++){
		Pkts[i].empty=true;
	}
}

int main(int argc, char **argv)
{

	struct ether_header *m_pEthhdr;
	struct iphdr *m_pIphdr;
    char tmp1[2000];
    memset(tmp1,0,sizeof(tmp1));
    char *head=tmp1;
    char *packet=tmp1+34;
    uint16_t len;

	struct Pkt *pkts;
	struct Fs *fs;
    FILE* f;
    if( (f=fopen("code.txt","r"))==NULL){
 	  printf("OPen File failure\n");
 	}
    int i=0;
    while (!feof(f))
    {
 	   //cout<<"begin to read code"<<endl;
 	   fread(head,34,1,f);
 	   printf("fread head ok");
 	   //cout<<"read head ok"<<endl;
 	   m_pEthhdr=(struct ether_header *)head;
 	   m_pIphdr=(struct iphdr *)(head+sizeof(struct ether_header));
 	   len = ntohs(m_pIphdr->tot_len);
 	   printf("length: %d\n",len);
 	   //cout<<"begin to read  packet"<<endl;
 	   //fread(packet,len-20,1,f);
 	   //cout<<"read  packet ok"<<endl;
 	   //cout<<"put packet to the hander"<<endl;
 	  printf("fread packet ok");

 	   if(i==31){

 		cudaMallocManaged(&pkts, 32*32*sizeof(Pkt));
 		cudaMallocManaged(&fs, 32*sizeof(Fs));
 		gpu_nf_process(pkts,fs,0x010203,32);
 		Pkt_reset(pkts,32*32);
 		cudaFree(pkts);
 		cudaFree(fs);
 		i=0;

 	   }


 	  Pkt_insert(pkts,head,i,len);
 	  i++;

   }

   fclose(f);

	return 0;
}
