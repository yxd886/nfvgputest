#ifndef D_FORMATPACKETA_H_
#define D_FORMATPACKETA_H_

#include <net/if.h>
#include <sys/types.h>
#include <rte_config.h>
//#include <netinet/ether.h>
#include <netinet/ip.h>
#include <netinet/tcp.h>
#include <netinet/udp.h>
#include <linux/if_pppox.h>
#include <linux/ppp_defs.h>
#include <linux/if_ether.h>
#include <sys/time.h>
#include <stdint.h>
#include <rte_ether.h>
#include <rte_ethdev.h>
#include "d_Public.cuh"


#define MAX_RAW_PACKET_SIZE 4096  /**< \brief maximun raw packet size */
#define PKT_METHOD_UNKNOWN 0 /**< \brief error, should not be unknown */
#define PKT_METHOD_SOCKET 1 /**< \brief received from packet_rx_ring socket */
#define PKT_METHOD_CAPFILE 2 /**< \brief received from lipbpcap file */
#define PKT_METHOD_LIBPCAP 3 /**< \brief received by libpcap */
#define PKT_METHOD_IPTABLES 4 /**< \brief received from iptables queue */

#define PKT_FLAG_USED 1 /**< \brief has packet */
#define PKT_FLAG_FREE 0 /**< \brief no packet */
#define PKT_FLAG_TRANSMIT 3/**< \brief transmit packet */
#define PKT_FLAG_DROP 4/**< \brief drop packet */

#define PKT_DIRECTION_UNKNOWN  0 /**< \brief packet direction unknown */
#define PKT_DIRECTION_LAN_TO_WAN   1 /**< \brief packet is sent from lan to wan */
#define PKT_DIRECTION_WAN_TO_LAN   2 /**< \brief packet is sent from wan to lan */
#define PKT_DIRECTION_LAN_TO_LAN   3 /**< \brief packet is sent from lan to lan */
#define PKT_DIRECTION_WAN_TO_WAN   4 /**< \brief packet is sent from wan to wan */

#define IP_HDR_PROTOCOL_OFF       9
#define VLAN_8021Q_IDT_LEN        4
#define VLAN_8021Q_IDT_EXTRA_LEN  2

#define PPPOE_HDR_LEN 8
#define ETH_PKT_LEN_MIN          54
#define ETH_PKT_LEN_MAX         1522


struct d_RawPacketInfo{
	timeval  m_timeval;
	uint32_t m_method;
	uint32_t m_index;
	uint32_t m_length;
	uint32_t m_ethhdr_off;
	uint32_t m_iphdr_off;
	uint32_t m_tcphdr_off;
};

/**
 *  Struct for packet communication
 *   */
typedef struct{
	int32_t flag; /**< \brief indicate packet element have received packet*/

	/**
	*  *  indicate packet receive method.
	*  *  @see PKT_METHOD_UNKNOWN
	*  *  @see PKT_METHOD_SOCKET
	*  *  @see PKT_METHOD_CAPFILE
	*  *  @see PKT_METHOD_LIBPCAP
	*  *  @see PKT_METHOD_IPTABLES
	*  */
	int16_t method;

	int16_t index; /**< \brief network interface index where packet received */

	int16_t ethhdr_off;
	int16_t iphdr_off;
	int16_t tcphdr_off;

	int16_t direct;

	int16_t length; /**< \brief real packet bytes in buffer */

	struct timeval time_val;

	char  packet[MAX_RAW_PACKET_SIZE]; /**< \brief packet content. @see MAX_RAW_PACKET_SIZE */
} d_SRawPacket;



class d_IFormatPacket{
public:
	__device__  virtual ~d_IFormatPacket(){};
	__device__  virtual void Format(Pkt *packet) = 0;
	__device__  virtual struct ether_hdr *GetEtherHeader() = 0;
	__device__  virtual u_int64_t GetDstMac() = 0;
	__device__  virtual u_int64_t GetSrcMac() = 0;

	__device__  virtual struct iphdr *GetIphdr() = 0;
	__device__  virtual u_int32_t GetDstIp() = 0;
	__device__  virtual u_int32_t GetSrcIp() = 0;
	__device__  virtual u_int8_t  GetIpProtocol() = 0;
	__device__  virtual u_int16_t GetIpPktLen() = 0;

	__device__  virtual struct tcphdr *GetTcphdr() = 0;
	__device__  virtual struct udphdr *GetUdphdr() = 0;
	__device__  virtual u_int16_t GetDstPort() = 0;
	__device__  virtual u_int16_t GetSrcPort() = 0;
	//virtual int16_t GetDirect() = 0;
	__device__  virtual u_int8_t *GetData() = 0;
	__device__  virtual int16_t  GetDataLen() = 0;
 // virtual SRawPacket *GetRawPacket() = 0;
};



class d_CFormatPacket : public d_IFormatPacket{
public:
	__device__ d_CFormatPacket(){}
	__device__ ~d_CFormatPacket(){}
	__device__  void Format(Pkt* packet){
		m_pPkt = packet->pkt;
		m_pEthhdr = &(packet->headinfo.m_pEthhdr);
		m_pIphdr = &(packet->headinfo.m_pIphdr);
		m_pTcphdr = &(packet->headinfo.m_pTcphdr);
		m_uPktLen = Ntohs(m_pIphdr->tot_len);
		m_pEthIndex = (int16_t*)(&m_pEthhdr->ether_type);
		m_pData = NULL;
		m_DataLen = 0;
		if (m_pIphdr){
			int16_t iplen=Ntohs(m_pIphdr->tot_len);
			int16_t offset;
			if (m_pIphdr->protocol == IPPROTO_TCP)
				offset = m_pIphdr->ihl * 4 + m_pTcphdr->doff * 4;
			else
				offset = m_pIphdr->ihl * 4 + 8;
			m_pData = (u_int8_t *)(packet + sizeof(struct ether_hdr) + offset);
			m_DataLen = iplen - offset;
			//gettimeofday(&_time,NULL);
		}
		return;
	}

	/**
	 *  Get ether header pointer
	 *  @return
	 *      \n NULL failed / not exist
	 *      \n point to ether header in packet
	 */
	__device__ struct ether_hdr *GetEtherHeader(){
	    return m_pEthhdr;
	}

	/**
	 *  Get Destination MAC Address
	 *  @return
	 *      \n NULL :failed / no destinatiom MAC address
	 *      \n pointer to ether destination MAC address
	 */
	__device__ u_int64_t GetDstMac(){
		if(m_pEthhdr){
			//return BCD2UInt64(m_pEthhdr->ether_dhost, 6);
			return 0;
		}else{
			return 0;
		}
	}

	/**
	 *  Get Source MAC Address
	 *  @return
	 *      \n NULL :failed / no source MAC address
	 *      \n pointer to ether source MAC address
	 */
	__device__ u_int64_t GetSrcMac(){
		if(m_pEthhdr){
			//return BCD2UInt64(m_pEthhdr->ether_shost, 6);
			return 0;
	}else{
			return 0;
		}
	}

	/**
	 *  Get IP header pointer
	 *  @return
	 *      \n NULL failed / not exist
	 *      \n point to IP header in packet
	 */
	__device__ struct iphdr *GetIphdr(){
		return m_pIphdr;
	}

	/**
	 *  Get Destination IP Address
	 *  @return
	 *      \n NULL :failed / no destinatiom IP address
	 *      \n pointer to destination IP address
	 */
	__device__ u_int32_t GetDstIp(){
		if(m_pIphdr){
			return m_pIphdr->daddr;
		}
		else{
			return 0;
		}
	}

	/**
	 *  Get Source IP Address
	 *  @return
	 *      \n NULL :failed / no source IP address
	 *      \n pointer to source IP address
	 */
	__device__ u_int32_t GetSrcIp(){
		if(m_pIphdr){
			return m_pIphdr->saddr;
		}else{
			return 0;
		}
	}

	/**
	 *  Get IP protocol in ip header
	 *  @return
	 *      \n NULL :failed / no exist
	 *      \n pointer to IP protocol
	 */
	__device__ u_int8_t  GetIpProtocol(){
		if(m_pIphdr){
			return m_pIphdr->protocol;
		}else{
			return 0;
		}
	}

	__device__ u_int16_t GetIpPktLen(){
		return m_uPktLen;
	}
	/**
	 *  Get TCP header pointer
	 *  @return
	 *      \n NULL failed / not exist
	 *      \n point to TCP header in packet
	 */
	__device__ struct tcphdr *GetTcphdr(){
		return m_pTcphdr;
	}

	/**
	 *  Get UDP header pointer
	 *  @return
	 *      \n NULL failed / not exist
	 *      \n point to UDP header in packet
	 */
	__device__ struct udphdr *GetUdphdr(){
		return (struct udphdr *)m_pTcphdr;
	}

	/**
	 *  Get Destination TCP/UDP port
	 *  @return
	 *      \n NULL :failed / no destinatiom TCP/UDP port
	 *      \n pointer to destination TCP/UDP port
	 */
	__device__ u_int16_t GetDstPort(){
		if(m_pTcphdr){
			return m_pTcphdr->dest;
		}else{
			return 0;
		}
	}

	/**
	 *  Get Source TCP/UDP port
	 *  @return
	 *      \n NULL :failed / no Source TCP/UDP port
	 *      \n pointer to Source TCP/UDP port
	 */
	__device__ u_int16_t GetSrcPort(){
		if(m_pTcphdr){
			return m_pTcphdr->source;
		}	else	{
			return 0;
		}
	}
	//int16_t GetDirect(){return m_pPacketData->direct;}
	__device__ u_int8_t *GetData()   {return m_pData;}
	__device__ int16_t  GetDataLen() {return m_DataLen;}
	//SRawPacket *GetRawPacket() {return m_pPacketData;}
	__device__ struct timeval *GetPacketTime() {return &(_time);}
	__device__ int16_t *GetEthIndex(){return m_pEthIndex;}

	__device__ char * GetPkt(){return m_pPkt;};
	__device__ u_int16_t GetPktLen(){return m_uPktLen;};


private:
	//SRawPacket *m_pPacketData;
	struct ether_hdr *m_pEthhdr;
	struct iphdr *m_pIphdr;
	struct tcphdr *m_pTcphdr;
	u_int8_t * m_pData;
	int16_t    m_DataLen;

	int16_t *m_pEthIndex;
	u_int16_t m_uPktLen;
	char * m_pPkt;
	struct timeval _time;
};



#endif
