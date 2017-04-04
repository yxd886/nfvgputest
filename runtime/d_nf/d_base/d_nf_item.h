#ifndef D_NF_ITEM_H
#define D_NF_ITEM_H

#include "d_network_function_base.cuh"

typedef unsigned short int uint16;

typedef unsigned long int uint32;



// 短整型大小端互换

#define BigLittleSwap16(A)  ((((uint16)(A) & 0xff00) >> 8) | (((uint16)(A) & 0x00ff) << 8))



// 长整型大小端互换

#define BigLittleSwap32(A)  ((((uint32)(A) & 0xff000000) >> 24) | (((uint32)(A) & 0x00ff0000) >> 8) | (((uint32)(A) & 0x0000ff00) << 8) | (((uint32)(A) & 0x000000ff) << 24))



static constexpr int max_chain_length = 8;;



// 本机大端返回1，小端返回0

__device__ int checkCPUendian()

{

       union{

              unsigned long int i;

              unsigned char s[4];

       }c;



       c.i = 0x12345678;

       return (0x12 == c.s[0]);

}



// 模拟htonl函数，本机字节序转网络字节序

__device__ unsigned long int Htonl(unsigned long int h)

{

       // 若本机为大端，与网络字节序同，直接返回

       // 若本机为小端，转换成大端再返回

       return checkCPUendian() ? h : BigLittleSwap32(h);

}



// 模拟ntohl函数，网络字节序转本机字节序

__device__ unsigned long int Ntohl(unsigned long int n)

{

       // 若本机为大端，与网络字节序同，直接返回

       // 若本机为小端，网络数据转换成小端再返回

       return checkCPUendian() ? n : BigLittleSwap32(n);

}



// 模拟htons函数，本机字节序转网络字节序

__device__ unsigned short int Htons(unsigned short int h)

{

       // 若本机为大端，与网络字节序同，直接返回

       // 若本机为小端，转换成大端再返回

       return checkCPUendian() ? h : BigLittleSwap16(h);

}



// 模拟ntohs函数，网络字节序转本机字节序

__device__ unsigned short int Ntohs(unsigned short int n)

{

       // 若本机为大端，与网络字节序同，直接返回

       // 若本机为小端，网络数据转换成小端再返回

       return checkCPUendian()? n:BigLittleSwap16(n);

}

//自定义实现计算字符串的长度

__device__ unsigned long myStrlen(char string[])
{
    unsigned long length = 0;

    while (string[length] != '\0') {
        length++;
    }

    return length;
}
//自定义实现字符串的拷贝
__device__ void myStrcpy(char* string1, const char* string2)
{
    int i = 0;
    while (string2[i] != '\0') {
        string1[i] = string2[i];
        i++;
    }
    string1[i] = '\0';
}
//自定义函数实现字符串的凭拼接
__device__ void myStrcat(char string1[], char string2[])
{
    //找string1的'\0'位置
    int i = 0;
    while (string1[i] != '\0') {
        i++;
    }

    //把string2加到string1后面
    int j = 0;
    while (string2[j] != '\0') {
        string1[i++] = string2[j++];
    }

//不要忘记在最后添加\0
    string1[i] = '\0';
}
//自定义函数实现字符串的比较
__device__ int myStrcmp(const char* string1, const char* string2)
{
    int i = 0;
    while (string1[i] == string2[i] && string1[i] != '\0') {
        i++;
    }

    return string1[i] - string2[i];
}


__device__ int myStrncmp ( const char * s1, const char * s2, size_t n)
{
  if ( !n )//n为无符号整形变量;如果n为0,则返回0

  return(0);

  //在接下来的while函数中

  //第一个循环条件：--n,如果比较到前n个字符则退出循环

  //第二个循环条件：*s1,如果s1指向的字符串末尾退出循环

  //第二个循环条件：*s1 == *s2,如果两字符比较不等则退出循环

  while (--n && *s1 && *s1 == *s2)
  {
  s1++;//S1指针自加1,指向下一个字符

  s2++;//S2指针自加1,指向下一个字符

  }
  return( *s1 - *s2 );//返回比较结果

}


__device__ int mySubstr(char dst[], const char src[],int start, int len)
{
    int i;
    for(i=0;i<len;i++)
    {
        dst[i]=src[start+i];    //从第start+i个元素开始向数组内赋值
    }
        dst[i]='\0';
        return i;
}

__device__ const char* myStrstr(const char *src, const char *dst)
{
      //入口参数检查
      assert(NULL != src && NULL != dst);
      #if 0
      if(src == NULL || dst == NULL)
      {
         // printf("usage: input error parameter\n");
      //exit(1);
    	  return NULL;
      }
      #endif
      while(NULL != src)
      {
          const char *temp1 = src;
          const char *temp2 = dst;
          const char *res = NULL;
          if(*temp1 == *temp2)
          {
                res = temp1;
                while(*temp1 && *temp2 && *temp1++ == *temp2++)
                ;

                if(*temp2 == '\0')
        {
                      return res;
        }
          }
          src++;
      }
      return NULL;
}


__device__ double myatof(const char* sptr)
{
    double temp=10;
    bool ispnum=true;
    double ans=0;
    if(*sptr=='-')//判断是否是负数
    {
        ispnum=false;
        sptr++;
    }
    else if(*sptr=='+')//判断是否为正数
    {
        sptr++;
    }

    while(*sptr!='\0')//寻找小数点之前的数
    {
        if(*sptr=='.'){ sptr++;break;}
        ans=ans*10+(*sptr-'0');
        sptr++;
    }
    while(*sptr!='\0')//寻找小数点之后的数
    {
        ans=ans+(*sptr-'0')/temp;
        temp*=10;
        sptr++;
    }
    if(ispnum) return ans;
    else return ans*(-1);
}

//函数名：myatoi
//功能：把字符串转化成int整型
//名字来源：my array to integer
//函数说明：接收一个字符串判断第一个字符的符号，没有符号默认为正值，然后对剩余字符串进行转换，//遇到\0结束，最后返回一个int

__device__ int myatoi(const char* sptr)
{

    bool ispnum=true;
    int ans=0;
    if(*sptr=='-')//判断是否是负数
    {
        ispnum=false;
        sptr++;
    }
    else if(*sptr=='+')//判断是否为正数
    {
        sptr++;
    }

    while(*sptr!='\0')//类型转化
    {
        ans=ans*10+(*sptr-'0');
        sptr++;
    }

    if(ispnum) return ans;
    else return ans*(-1);
}

class Mystring{
public:
	__device__ Mystring(){

		p=(char*)malloc(40*sizeof(char));
		memset(p,0,40);
	}
	__device__ Mystring(const char* src){

		p=(char*)malloc(40*sizeof(char));
		memset(p,0,40);
		myStrcpy(this->p,src);
	}
	__device__ ~Mystring(){

		free(p);
	}
	__device__ Mystring& append(const char* src, int i){
		char dst[20];
		memset(dst,0,20);

		mySubstr(dst,src,0,i);
		myStrcat(this->p,dst);
		return *this;

	}
	__device__ int compare(const char* src){

		return(myStrcmp(src,this->p));

	}
	__device__ int size(){
		return myStrlen(this->p);
	}
	__device__ Mystring& substr(int start,int len){
		char dst[20];
		memset(dst,0,20);
		mySubstr(dst,this->p,start,len);
		Mystring ret(dst);
		return ret;

	}
	__device__ bool find(const char* dst ){
		if(myStrstr(this->p,dst)==NULL){
			return false;
		}
		else
			return true;
	}
	__device__ char* c_str(){
		return this->p;
	}
private:
	char* p;
};



struct d_flow_actor_nfs{
  d_network_function_base* nf[max_chain_length];
};

struct d_flow_actor_fs{
  char* nf_flow_state_ptr[max_chain_length];
};

struct d_flow_actor_fs_size{
  size_t nf_flow_state_size[max_chain_length];
};

static_assert(sizeof(d_flow_actor_nfs) == 64, "flow_actor_nfs can't fit into a cache line");

static_assert(sizeof(d_flow_actor_fs) == 64, "flow_actor_fs can't fit into a cache line");

static_assert(sizeof(d_flow_actor_fs_size) == 64, "flow_actor_fs_size can't fit into a cache line");

static_assert(std::is_pod<d_flow_actor_nfs>::value, "flow_actor_nfs is not pod");

static_assert(std::is_pod<d_flow_actor_fs>::value, "flow_actor_fs is not pod");

static_assert(std::is_pod<d_flow_actor_fs_size>::value, "flow_actor_fs_size is not pod");


#endif
