#ifndef CAF_FW_HEADINFO_H
#define CAF_FW_HEADINFO_H


typedef short Bool;

#define SRC 0
#define DEST 1

#define PERMIT 1
#define REJECT 0

#define ANY_ADDR 0
#define ANY_PORT 0xffff
#define ANY_PROTOCOL 0xff
#define ANY_TIME(tm) (tm.valid == 0)

#define MASK_IP(x, mask) (x & (0xffffffff << (!mask ? 0 : (32 - mask))))

#include "../d_base/Pkt.h"
struct d_firewall_state{
  int match_no;
  int drop_no;
  int pass_no;
  bool current_pass;
};

struct d_rule{
  struct{
    uint32_t addr;        //IP地址
    uint8_t mask;         //掩码
  }saddr, daddr;             //源IP地址，目的IP地址
  uint16_t sport, dport;     //源端口，目的端口
  uint8_t protocol;             //协议类型
  int action;               //动作
};


#endif
