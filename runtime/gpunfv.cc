
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
#include <time.h>
#include   <sys/time.h>

#include <cuda_runtime.h>

#include <helper_cuda.h>

#include "d_nf/d_base/d_nf_processor.cuh"
#include "d_nf/d_base/Pkt.h"


/**
 * This macro checks return value of the CUDA runtime call and exits
 * the application if the call failed.
 *
 * See cuda.h for error code descriptions.
 */
void Pkt_insert(struct Pkt* Pkts,char* pkt,int i,int total_len){

	char* dst=Pkts[i].pkt;
	memcpy(dst,pkt,total_len);
	Pkts[i].empty=false;

}

void Pkt_reset(struct Pkt* Pkts,int num){

	for(int i=0;i<num;i++){
		Pkts[i].empty=true;
	}
}

void test(){

	printf("sizeof bool: %d",sizeof(bool));
	printf("sizeof PKT: %d",sizeof(Pkt));
	printf("sizeof FS: %d",sizeof(Fs));
	struct ether_header *m_pEthhdr;
	struct iphdr *m_pIphdr;
    char tmp1[2000];
    memset(tmp1,0,sizeof(tmp1));
    char *head=tmp1;
    char *packet=tmp1+34;
    uint16_t len;

	char *pkts=NULL;
	char *fs=NULL;

	cudaError_t err = cudaSuccess;

	err=cudaMallocManaged(&pkts, 32*32*sizeof(Pkt));
	if(err!=cudaSuccess){
			printf("cuda malloc fail，error code: %s\n",cudaGetErrorString(err));
	}
	err=cudaMallocManaged(&fs, 32*sizeof(Fs));
	if(err!=cudaSuccess){
			printf("cuda malloc fail，error code: %s\n",cudaGetErrorString(err));
	}

	Pkt_reset((Pkts*)pkts,32*32);

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
 	   //cout<<"begin to read code"<<endl;
    	//printf("begin to read head\n");
       fread(head,34,1,f);
 	   //printf("fread head ok\n");
 	   //cout<<"read head ok"<<endl;
 	  m_pEthhdr=(struct ether_header *)head;
 	  m_pIphdr=(struct iphdr *)(head+sizeof(struct ether_header));
 	   len = ntohs(m_pIphdr->tot_len);
 	   //printf("length: %d\n",len);
 	   //cout<<"begin to read  packet"<<endl;
 	   fread(packet,len-20,1,f);
 	   //cout<<"read  packet ok"<<endl;
 	   //cout<<"put packet to the hander"<<endl;
 	  //printf("fread packet ok\n");

 	   if(i==31){



		char* dst=pkts[i].pkt;
		memcpy(dst,head,len+14);
 		gpu_nf_process(pkts,fs,0x010203,32);
 		//cudaFree(pkts);
		//cudaFree(fs);

 		//printf("i==31\n");
 		//fflush(stdout);
/*
 		err=cudaMallocManaged(&pkts, 32*32*sizeof(Pkt));
 		if(err!=cudaSuccess){
 			printf("cuda malloc fail，error code: %s\n",cudaGetErrorString(err));
 		}
 		err=cudaMallocManaged(&fs, 32*sizeof(Fs));
 		if(err!=cudaSuccess){
 			printf("cuda malloc fail，error code: %s\n",cudaGetErrorString(err));
 		}
 		*/
 		Pkt_reset(pkts,32*32);
 		i=0;

 	   }else{
		//fflush(stdout);
		//printf("i=%d\n",i);
		char* dst=pkts[i].pkt;
		memcpy(dst,head,len+14);

		i++;

 	   }




   }

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
	//test();
	return 0;
}

