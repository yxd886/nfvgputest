#ifndef HASHAA_H
#define HASHAA_H

#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <string.h>
#define D_NULLKEY 0 // 0为无记录标志
#define N 10  // 数据元素个数



typedef char* d_KeyType;// 设关键字域为char*
typedef struct{
	char key[20];
	char value[100];
}d_ElemType; // 数据元素类型



// 开放定址哈希表的存储结构

typedef struct{
	d_ElemType *elem; // 数据元素存储基址，动态分配数组
	int count; // 当前数据元素个数
	int sizeindex; // hashsize[sizeindex]为当前容量
}d_HashTable;


#define SUCCESS 1
#define UNSUCCESS 0
#define DUPLICATE -1


// 构造一个空的哈希表
__device__ int d_InitHashTable(d_HashTable *H);

//  销毁哈希表H
__device__ void d_DestroyHashTable(d_HashTable *H);
// 一个简单的哈希函数(m为表长，全局变量)

__device__ unsigned int d_Hash(char *str);

// 开放定址法处理冲突
__device__ void d_collision(int *p,int d);
// 算法9.17
// 在开放定址哈希表H中查找关键码为K的元素,若查找成功,以p指示待查数据
// 元素在表中位置,并返回SUCCESS;否则,以p指示插入位置,并返回UNSUCCESS
// c用以计冲突次数，其初值置零，供建表插入时参考。
__device__ int d_SearchHash(d_HashTable H,d_KeyType K,int *p,int *c);
__device__ int d_InsertHash(d_HashTable *,d_ElemType); // 对函数的声明
// 重建哈希表
__device__ void d_RecreateHashTable(d_HashTable *H);
// 算法9.18
// 查找不成功时插入数据元素e到开放定址哈希表H中，并返回1；
// 若冲突次数过大，则重建哈希表。
__device__ int d_InsertHash(d_HashTable *H,d_ElemType e);
// 按哈希地址的顺序遍历哈希表
__device__ void TraverseHash(d_HashTable H,void(*Vi)(int,d_ElemType));
// 在开放定址哈希表H中查找关键码为K的元素,若查找成功,以p指示待查数据
// 元素在表中位置,并返回SUCCESS;否则,返回UNSUCCESS
__device__ int d_Find(d_HashTable H,d_KeyType K,int *p);
__device__ void d_print(int p,d_ElemType r);


__device__ static int d_hashsize[]={11,19,29,37}; // 哈希表容量递增表，一个合适的素数序列
__device__ static int d_m=0; // 哈希表表长，全局变量


// 构造一个空的哈希表
__device__ int d_InitHashTable(d_HashTable *H){
	int i;
	(*H).count=0; // 当前元素个数为0
	(*H).sizeindex=0; // 初始存储容量为hashsize[0]
	d_m=d_hashsize[0];
	(*H).elem=(d_ElemType*)malloc(d_m*sizeof(d_ElemType));
	if(!(*H).elem)
	  return 0; // 存储分配失败
	for(i=0;i<d_m;i++)
	*((*H).elem[i].key)=D_NULLKEY; // 未填记录的标志

	return 1;
}
//  销毁哈希表H
__device__ void d_DestroyHashTable(d_HashTable *H){
	free((*H).elem);
	(*H).elem=NULL;
	(*H).count=0;
	(*H).sizeindex=0;
}
// 一个简单的哈希函数(m为表长，全局变量)

__device__ unsigned int d_Hash(char *str){
	unsigned int hash = 0;

	while (*str){
		// equivalent to: hash = 65599*hash + (*str++);
		hash = (*str++) + (hash << 6) + (hash << 16) - hash;
	}

	return (hash & 0x7FFFFFFF)%d_m;
}

// 开放定址法处理冲突
__device__ void d_collision(int *p,int d){
	*p=(*p+d)%d_m;
}
// 算法9.17
// 在开放定址哈希表H中查找关键码为K的元素,若查找成功,以p指示待查数据
// 元素在表中位置,并返回SUCCESS;否则,以p指示插入位置,并返回UNSUCCESS
// c用以计冲突次数，其初值置零，供建表插入时参考。
__device__ int d_SearchHash(d_HashTable H,d_KeyType K,int *p,int *c){
	*p=d_Hash(K); // 求得哈希地址
	while(*(H.elem[*p].key)!=D_NULLKEY&&!(myStrcmp(K,H.elem[*p].key)==0)){
	// 该位置中填有记录．并且关键字不相等
		(*c)++;
		if(*c<d_m)
			d_collision(p,*c); // 求得下一探查地址p
		else
			break;
	}
	if (myStrcmp(K,H.elem[*p].key)==0)
		return SUCCESS; // 查找成功，p返回待查数据元素位置
	else
		return UNSUCCESS; // 查找不成功(H.elem[p].key==NULLKEY)，p返回的是插入位置
}
__device__ int d_InsertHash(d_HashTable *,d_ElemType); // 对函数的声明
// 重建哈希表
__device__ void d_RecreateHashTable(d_HashTable *H){
	int i,count=(*H).count;
	d_ElemType *p,*elem=(d_ElemType*)malloc(count*sizeof(d_ElemType));
	p=elem;
	//printf("重建哈希表\n");
	for(i=0;i<d_m;i++) // 保存原有的数据到elem中
		if(((*H).elem+i)->key!=D_NULLKEY) // 该单元有数据
			*p++=*((*H).elem+i);
	(*H).count=0;
	(*H).sizeindex++; // 增大存储容量
	d_m=d_hashsize[(*H).sizeindex];
	free(H->elem);
	p=(d_ElemType*)malloc(d_m*sizeof(d_ElemType));
	if(!p)
		return; // 存储分配失败
	(*H).elem=p;
	for(i=0;i<d_m;i++)
		*((*H).elem[i].key)=D_NULLKEY; // 未填记录的标志(初始化)
	for(p=elem;p<elem+count;p++) // 将原有的数据按照新的表长插入到重建的哈希表中
		d_InsertHash(H,*p);
}
// 算法9.18
// 查找不成功时插入数据元素e到开放定址哈希表H中，并返回1；
// 若冲突次数过大，则重建哈希表。
__device__ int d_InsertHash(d_HashTable *H,d_ElemType e){
	int c,p;
	c=0;
	if(d_SearchHash(*H,e.key,&p,&c)) // 表中已有与e有相同关键字的元素
		return DUPLICATE;
	else if(c<d_hashsize[(*H).sizeindex]/2){
  // 插入e
		(*H).elem[p]=e;
		++(*H).count;
		return 1;
 }else
	 d_RecreateHashTable(H); // 重建哈希表

	return 0;
}
// 按哈希地址的顺序遍历哈希表
__device__ void TraverseHash(d_HashTable H,void(*Vi)(int,d_ElemType)){
	int i;
	//printf("哈希地址0～%d\n",d_m-1);
	for(i=0;i<d_m;i++)
		if(*(H.elem[i].key)!=D_NULLKEY) // 有数据
			Vi(i,H.elem[i]);
}
// 在开放定址哈希表H中查找关键码为K的元素,若查找成功,以p指示待查数据
// 元素在表中位置,并返回SUCCESS;否则,返回UNSUCCESS
__device__ int d_Find(d_HashTable H,d_KeyType K,int *p){
	int c=0;
	*p=d_Hash(K); // 求得哈希地址
	while(*(H.elem[*p].key)!=D_NULLKEY&&!(myStrcmp(K,H.elem[*p].key)==0)){ // 该位置中填有记录．并且关键字不相等
		c++;
		if(c<d_m)
			d_collision(p,c); // 求得下一探查地址p
		else
			return UNSUCCESS; // 查找不成功(H.elem[p].key==NULLKEY)
	}
	if (myStrcmp(K,H.elem[*p].key)==0)
		return SUCCESS; // 查找成功，p返回待查数据元素位置
	else
		return UNSUCCESS; // 查找不成功(H.elem[p].key==NULLKEY)
}
__device__ void d_print(int p,d_ElemType r){
	//printf("address=%d (%s,%s)\n",p,r.key,r.value);
}





#endif
