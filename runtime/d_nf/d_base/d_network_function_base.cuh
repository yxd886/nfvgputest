#ifndef D_NETWORK_FUNCTION_H
#define D_NETWORK_FUNCTION_H
// CUDA runtime
#include <cuda_runtime.h>
#include <glog/logging.h>

// helper functions and utilities to work with CUDA
#include <helper_functions.h>
#include <helper_cuda.h>
#include "Pkt.h"

class d_network_function_base{
public:

  __device__ explicit d_network_function_base(size_t nf_state_size, uint8_t nf_id)
    : nf_state_size_(nf_state_size), array_(0), nf_id_(nf_id){
  }
/*
  inline void init_ring(size_t nf_state_num){
    array_ = reinterpret_cast<char*>(mem_alloc(nf_state_size_*nf_state_num));
    ring_buf_.init(nf_state_num);
    for(size_t i=0; i<nf_state_num; i++){
      ring_buf_.push(array_+i*nf_state_size_);
    }
  }
  */

  __device__ virtual ~d_network_function_base(){}


  __device__ char* allocate(){

	char* d_p;
	 d_p=(char*)malloc(nf_state_size_*sizeof(char));


	return d_p;
  }

  __device__ void deallocate(char* state_ptr){

	  free(state_ptr);

  }


  __device__ virtual void nf_logic(Pkt* pkt, char* state_ptr) = 0;

  __device__ inline size_t get_nf_state_size(){
    return nf_state_size_;
  }

  __device__ inline uint8_t get_nf_id(){
    return nf_id_;
  }

private:
  size_t nf_state_size_;
  char* array_;
  //simple_ring_buffer<char> ring_buf_;
  uint8_t nf_id_;
};

#endif
