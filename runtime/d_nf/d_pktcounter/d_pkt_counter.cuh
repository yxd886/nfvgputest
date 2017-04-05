#ifndef PKT_COUNTER_H
#define PKT_COUNTER_H

//#include "../../bessport/packet.h"
#include "d_pkt_counter_fs.cuh"

class d_pkt_counter{
public:
	__device__ d_pkt_counter(){}
	__device__ ~d_pkt_counter(){}
	__device__ inline void nf_logic_impl(Pkt* pkt, d_pkt_counter_fs* fs){
    fs->counter += 1;
  }
};

#endif
