#include "d_network_function_base.cuh"
#include "d_network_function_derived.cuh"
#include "d_nf_item.h"
#include "../d_firewall/d_firewall.cuh"
#include "../d_flowmonitor/d_flow_monitor.cuh"
#include "../d_httpparser/d_http_parser.cuh"
#include "../d_pktcounter/d_pkt_counter.cuh"
#include "Pkt.h"
#include "d_nf_processor.cuh"

__device__ void Init_nfs(struct d_flow_actor_nfs* nfs){


	nfs->nf[1]=new d_network_function_derived<d_pkt_counter, d_pkt_counter_fs>(1);
	nfs->nf[2]=new d_network_function_derived<d_flow_monitor, d_flow_monitor_fs>(2);
	nfs->nf[3]=new d_network_function_derived<d_firewall, d_firewall_fs>(3);
	nfs->nf[4]=new d_network_function_derived<d_http_parser, d_http_parser_fs>(4);

}



__device__ uint8_t compute_network_function(uint64_t s, int pos){
  return static_cast<uint8_t>((s>>(8*pos))&0x00000000000000FF);
}

__device__ int compute_service_chain_length(uint64_t s){
  int length = 0;
  bool encounter_zero = false;
  for(int i=0; i<8; i++){
    uint8_t nf =
        static_cast<uint8_t>((s>>(8*i))&0x00000000000000FF);
    if(nf>0){
      length+=1;
      if(encounter_zero){
        return -1;
      }
    }
    else{
      encounter_zero = true;
    }
  }
  return length;
}


__global__ void
Runtask(Pkt* pkts, Fs* fs, uint64_t service_chain,int packet_num)
{


	struct d_flow_actor_nfs  nfs;
	Init_nfs(&nfs);
	int chain_len=compute_service_chain_length(service_chain);
	int i = blockDim.x * blockIdx.x + threadIdx.x;

    if (i < packet_num)
    {
    	int j=i;
    	while(pkts[j].empty!=true){
    		for(int k=0; k<chain_len; k++){
    			int nf_id=compute_network_function(service_chain,k);
    			nfs.nf[nf_id]->nf_logic(pkts[j].pkt,fs[j%packet_num].fs[nf_id]);
    		}
    		j+=packet_num;

    	}
    }
}



void gpu_nf_process(Pkt* pkts,Fs* fs,uint64_t service_chain,int packet_num){

    int threadsPerBlock = 256;
    int blocksPerGrid =(packet_num + threadsPerBlock - 1) / threadsPerBlock;
    //printf("CUDA kernel launch with %d blocks of %d threads\n", blocksPerGrid, threadsPerBlock);
    Runtask<<<blocksPerGrid, threadsPerBlock>>>(pkts, fs, service_chain, packet_num);
    cudaDeviceSynchronize();


}


