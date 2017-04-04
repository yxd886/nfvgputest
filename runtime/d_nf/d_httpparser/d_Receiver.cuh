#ifndef D_RECEIVE_H_
#define D_RECEIVE_H_

#include "d_Public.cuh"
#include "d_Handle.cuh"
#include "d_BehaviorInfo.cuh"
#include "d_FormatPacket.cuh"

class d_Receiver{
public:
	__device__ d_Receiver(){
	_handle.Init();

  }

	__device__ 	~d_Receiver(){}
	__device__ void Work(char* msg, d_http_parser_fsPtr& sesp){

		HandleMessage( msg,sesp);


	}


private:
	__device__ 	void HandleMessage(char* msg, d_http_parser_fsPtr& sesp){
		if(msg == NULL){
			//cout<<"message is empty, return"<<endl;
			return;
		}
		//格式化一个二进制包
		d_CFormatPacket packet;
		packet.Format(msg);
		//	 printf("packet.GetDstPort:%x\n",packet.GetDstPort());
		//	 printf("ntoh packet.GetDstPort:%x\n",ntohs(packet.GetDstPort()));
		//	 printf("packet.GetSrcPort:%x\n",packet.GetSrcPort());
		//	 printf("ntoh packet.GetSrcPort:%x\n",ntohs(packet.GetSrcPort()));
		d_CSharedBehaviorInfo info;
		if(packet.GetIpProtocol()==IPPROTO_TCP&&Ntohs(packet.GetDstPort())==0x50){
			//info.CSharedBehaviorInfo(ntohl(packet.GetDstIp()),ntohl((uint32_t)packet.GetDstPort()),packet.GetIpProtocol());
			info.m_nIP=Ntohl(packet.GetDstIp());
			info.m_nPort=Ntohs(packet.GetDstPort());
			info.m_nBehaviorId=packet.GetIpProtocol();
			info.m_nIdtMatchWay=C2S_MATCH;
			//printf("Client to server/n");
		 }else if(packet.GetIpProtocol()==IPPROTO_TCP&&Ntohs(packet.GetSrcPort())==0x50){
				//info.CSharedBehaviorInfo(ntohl(packet.GetSrcIp()),ntohs(packet.GetSrcPort()),packet.GetIpProtocol());
				info.m_nIP=Ntohl(packet.GetSrcIp());
				info.m_nPort=Ntohs(packet.GetSrcPort());
				info.m_nBehaviorId=packet.GetIpProtocol();
				info.m_nIdtMatchWay=S2C_MATCH;
				//printf("Server to client\n");
		 }else{


			 return;//not http packet
		 }
		 d_CSharedBehaviorInfo* pInfo=&info;

		_handle.Process(packet,pInfo,sesp);

		return;
	}

    //zmq::context_t _ctx;
    //zmq::socket_t _socket;
    d_CHandle  _handle;
};












#endif
