#ifndef D_CAF_FM_HEADINFO_HPP
#define D_CAF_FM_HEADINFO_HPP

#include <netinet/ip.h>
#include <netinet/tcp.h>
#include <netinet/udp.h>
//#include <netinet/in.h>
#include <rte_ether.h>
#include <rte_ethdev.h>

struct d_head_info{
  struct ether_hdr *m_pEthhdr;
  struct iphdr *m_pIphdr;
  struct tcphdr* m_pTcphdr;
  uint8_t protocol;
};
#endif
