#ifndef D_BEHAVIORINFO_H_
#define D_BEHAVIORINFO_H_

#include "d_Public.cuh"


struct d_CSharedBehaviorInfo{
	__device__ d_CSharedBehaviorInfo() :
		m_nIP(0),
		m_nPort(0),
		m_nBehaviorId(0),
		m_nIdtMatchWay(UNK_MATCH){

	}

	__device__ d_CSharedBehaviorInfo(const d_CSharedBehaviorInfo& anoter ) :
	 m_nIP(anoter.m_nIP),
	 m_nPort(anoter.m_nPort),
	 m_nBehaviorId(anoter.m_nBehaviorId),
	 m_nIdtMatchWay(anoter.m_nIdtMatchWay){

  }

	__device__ d_CSharedBehaviorInfo(const uint32_t ip,const uint32_t port,const uint32_t bhvId) :
		m_nIP(ip),
		m_nPort(port),
		m_nBehaviorId(bhvId){

		m_nIdtMatchWay = UNK_MATCH;
	}


	uint32_t m_nIP;     ///主机序
	uint32_t m_nPort;   ///主机序
	uint32_t m_nBehaviorId;
	uint32_t m_nIdtMatchWay;
};

typedef d_CSharedBehaviorInfo d_CBhvInf;

#endif /* BEHAVIORINFO_H_ */
