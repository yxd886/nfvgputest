#ifndef D_HANDLEA_H_
#define D_HANDLEA_H_

#include "d_Public.cuh"
#include "d_BehaviorInfo.cuh"
#include "d_FormatPacket.cuh"
#include "d_SessionHash.cuh"
#include "d_HttpParse.cuh"
#include <stdio.h>

class d_CHandle{
public:
	__device__ d_CHandle();
	__device__ ~d_CHandle();
	__device__ void Init();
	__device__ void Process(d_CFormatPacket packet, d_CSharedBehaviorInfo* pInfo, d_http_parser_fsPtr& sesp);
	__device__ void Create(d_IFormatPacket *pPacket,d_CSharedBehaviorInfo* pInfo,d_http_parser_fsPtr& ptr);

private:
	__device__ void TimeOutCheck();


	d_CHttpParse         _httpParse;


};




__device__ void d_CHandle::Process(d_CFormatPacket packet, d_CSharedBehaviorInfo* pInfo, d_http_parser_fsPtr& fhs)
{



	if( !pInfo){
		//log handle.process arguament is null
		return;
	}

	if(fhs->counter==0){
		//如果不存在，则创建新会话
		//   		printf("new session created!\n");
		//getchar();
		Create(&packet,pInfo,fhs);

	}
	fhs->counter++;

	//开始组包

	if(packet.GetTcphdr()->fin == 1 || packet.GetTcphdr()->rst == 1){
		//log 会话结束,session over
		//  	printf("session over\n");
		_httpParse.Parse(fhs);

		return;
	}


	if(packet.GetDataLen() == 0){
		//log zero length
		// 	printf("data zero!\n");
		return;
	}

	fhs->SeqNo=Ntohl(packet.GetTcphdr()->seq);
	fhs->AckSeqNo=Ntohl(packet.GetTcphdr()->ack_seq);

	if(pInfo->m_nIdtMatchWay == UNK_MATCH){
		//log unknown match
		//printf("unknow match!\n");
		return;
	}else if(pInfo->m_nIdtMatchWay == C2S_MATCH){
		 // printf("C2S\n");
		if(d_GetBufLen(fhs->ReqBuf) > 0 && d_GetBufLen(fhs->RspBuf) > 0){
			//printf("enter sesptr->ReqBuf.GetBufLen() > 0 && sesptr->RspBuf.GetBufLen() > 0\n");
			_httpParse.Parse(fhs);

		}

		if(d_GetBufLen(fhs->ReqBuf) == 0 && fhs->Result.RequestTimeStamp == 0){
			//the first request packet. we will get timestamp from this packet
			//printf("first request packet!\n");
			fhs->Result.RequestTimeStamp=packet.GetPacketTime()->tv_sec * 1000000LL + packet.GetPacketTime()->tv_usec;
		}
		//printf("appending request buffer!\n");
		if(!d_Append(fhs->ReqBuf,(char*) packet.GetData(), (size_t) packet.GetDataLen())){

			//log  c2s append date error
			return;
		}
	}else if(pInfo->m_nIdtMatchWay == S2C_MATCH){
		//printf("S2C\n");
		if(d_GetBufLen(fhs->RspBuf) == 0 && fhs->Result.ResponseTimeStamp == 0){
			//the first response packet. we will get timestamp from this packet
			//printf("first response packet!\n");
			fhs->Result.ResponseTimeStamp = packet.GetPacketTime()->tv_sec * 1000000LL + packet.GetPacketTime()->tv_usec;

		}

  		//printf("appending respone buffer!\n");
		if(!d_Append(fhs->RspBuf,(char*) packet.GetData(), (size_t) packet.GetDataLen())){
			//log  c2s append date error
			//printf("appending respone buffer failure!\n");
			return;
		}
		//printf("RspBuf after append: %s \n",fhs->RspBuf.buf);
	}
	unsigned int i;
	//printf("session request buffer:%s\n\n\n\n",GetBuf(fhs->ReqBuf,i));
	//getchar();
	//printf("session response buffer:%s\n",GetBuf(fhs->RspBuf,i));
	return;
}

__device__ d_CHandle::d_CHandle(){
}

__device__ d_CHandle::~d_CHandle(){
}

__device__ void d_CHandle::Init(){

	_httpParse.Init();

}



__device__ void d_CHandle::Create(d_IFormatPacket *pPacket,d_CSharedBehaviorInfo* pInfo,d_http_parser_fsPtr& ptr){



	d_http_parser_fs_Reset(ptr);
	if(pInfo->m_nIP == Ntohl(pPacket->GetSrcIp()) && pInfo->m_nPort == Ntohs(pPacket->GetSrcPort())){
		ptr->ServerIp   = Ntohl(pPacket->GetSrcIp());
		ptr->ClientIp   = Ntohl(pPacket->GetDstIp());
		ptr->ServerPort = Ntohs(pPacket->GetSrcPort());
		ptr->ClientPort = Ntohs(pPacket->GetDstPort());
		ptr->ServerMac  = pPacket->GetSrcMac();
		ptr->ClientMac  = pPacket->GetDstMac();
		ptr->Protocol   = pInfo->m_nBehaviorId;

		ptr->CreatedTime = 0;
		ptr->RefreshTime = ptr->CreatedTime;
		ptr->counter=0;
	}else{
		ptr->ServerIp   = Ntohl(pPacket->GetDstIp());
		ptr->ClientIp   = Ntohl(pPacket->GetSrcIp());
		ptr->ServerPort = Ntohs(pPacket->GetDstPort());
		ptr->ClientPort = Ntohs(pPacket->GetSrcPort());
		ptr->ServerMac  = pPacket->GetDstMac();
		ptr->ClientMac  = pPacket->GetSrcMac();
		ptr->Protocol   = pInfo->m_nBehaviorId;

		ptr->CreatedTime = 0;
		ptr->RefreshTime = ptr->CreatedTime;
		ptr->counter=0;

	}



}


#endif
