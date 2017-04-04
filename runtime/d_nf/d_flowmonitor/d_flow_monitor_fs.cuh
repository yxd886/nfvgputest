#ifndef D_FM_SESSIONHASH_H_
#define D_FM_SESSIONHASH_H_

#include <rte_config.h>
#include <rte_mbuf.h>
#include <rte_ether.h>
#include <rte_ethdev.h>
#include <asm-generic/int-ll64.h>

#include <iostream>
#include <fstream>
#include <string>
#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <stdlib.h>
#include <vector>
#include <sys/time.h>
#include <time.h>
#include <deque>
#include <set>
#include <map>
#include <list>



struct d_flow_monitor_fs
{

    uint32_t SrcIp;
    uint32_t DstIp;
    uint16_t SrcPort;
    uint16_t DstPort;
    uint8_t protocol;
    //time_t   CreatedTime;
    //time_t   RefreshTime;
    uint64_t no_tcp;
    uint64_t no_udp;
    uint64_t no_icmp;
    uint64_t no_total;
    int counter;

};




#endif
