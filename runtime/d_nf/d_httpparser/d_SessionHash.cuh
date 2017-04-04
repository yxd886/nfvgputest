#ifndef D_SESSIONHASH_H_
#define D_SESSIONHASH_H_

#include "d_Public.cuh"
#include "d_Buffer.cuh"
#include "d_FormatPacket.cuh"
#include "d_BehaviorInfo.cuh"
#include <rte_config.h>
#include <rte_mbuf.h>
#include <rte_ether.h>
#include <rte_ethdev.h>

struct d_http_parser_fs{

	uint32_t ServerIp;
	uint32_t ClientIp;
	uint16_t ServerPort;
	uint16_t ClientPort;
	uint64_t ServerMac;
	uint64_t ClientMac;

	time_t   CreatedTime;
	time_t   RefreshTime;
	uint32_t SeqNo;
	uint32_t AckSeqNo;

	uint8_t Protocol;
	d_CBuffer  ReqBuf;
	d_CBuffer  RspBuf;
	CResult  Result;
	int counter;
};
typedef d_http_parser_fs*    d_http_parser_fsPtr;

__device__ void d_http_parser_fs_Reset(d_http_parser_fsPtr& ptr);




__device__ void d_http_parser_fs_Reset(d_http_parser_fsPtr& ptr){
	d_CBuffer_Reset(ptr->ReqBuf);
	d_CBuffer_Reset(ptr->RspBuf);
	d_CResult_Reset(ptr->Result);

}




#endif
