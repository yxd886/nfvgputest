// This module is where we poll input/output port and schedule
// execution_context actors.

#ifndef PKT_H
#define PKT_H
#define PKT_SIZE 400
#define FS_STATE_MAX_SIZE 160
#include <rte_ether.h>

struct d_headinfo{
  struct ether_hdr m_pEthhdr;
  struct iphdr m_pIphdr;
  struct tcphdr m_pTcphdr;
  struct udphdr m_pUdphdr;
  uint8_t protocol;
  uint8_t is_tcp;
  uint8_t is_udp;
};


struct  Pkt{
	char empty;
	char pad1;
	char pad2;
	char pad3;
	uint64_t pad4;
	uint64_t pad5;
	struct d_headinfo headinfo;

	char pkt[PKT_SIZE];
};

struct  Fs{
	uint64_t actor_id_64;
	char fs[8][FS_STATE_MAX_SIZE];
};



#endif
