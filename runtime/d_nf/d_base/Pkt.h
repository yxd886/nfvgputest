// This module is where we poll input/output port and schedule
// execution_context actors.

#ifndef PKT_H
#define PKT_H
#define PKT_SIZE 319
#define FS_STATE_MAX_SIZE 192

#pragma pack(32)
struct  Pkt{
	bool empty;
	char pkt[PKT_SIZE];
};

#pragma pack(32)
struct  Fs{
	uint64_t actor_id_64;
	char fs[8][FS_STATE_MAX_SIZE];
};



#endif
