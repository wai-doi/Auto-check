#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>  
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>
#include "winlib.h"

#define DEFAULT_WIDTH    300
#define DEFAULT_HEIGHT   300
#define DISPLAY_DEPTH    8

FILE *fp;

int width= DEFAULT_WIDTH;
int height= DEFAULT_HEIGHT;

char sbuf[256];
char XinitBuf[] = {0x42, 00, 00 , 0x0b, 
                   0x00, 00, 00 , 0x12, 
                   0x00, 0x10, 00 , 00};

char iniBuf[256];



/* create a connection to winserver */
int srv_sock;
int clt_sock;
struct sockaddr_in srcAddr;
struct sockaddr_in dstAddr;
int dstAddrSize = sizeof(dstAddr);
int port = 6000;
char dstIP[128];

void connect_sock(){
  char c=0;
  
  /*  printf("Server/Client?(s/c)");
      scanf("%c",&c); */
  if( c=='s') {
    srcAddr.sin_port = htons(port);
    srcAddr.sin_family = AF_INET;
    srcAddr.sin_addr.s_addr = htonl(INADDR_ANY);

    srv_sock = socket(AF_INET,SOCK_STREAM,0);
    bind(srv_sock, (struct sockaddr *)&srcAddr, sizeof(srcAddr));
    listen(srv_sock,1);
    printf("Waiting for connection at port %d\n",port);

    clt_sock = accept(srv_sock,(struct sockaddr *)&dstAddr,&dstAddrSize);
    printf("Connected from %s\n", inet_ntoa(dstAddr.sin_addr));

  }else{
    FILE *fp;
    int i;
    char *portbuf = getenv("DISPLAY");
    char *hostname = getenv("HOSTNAME");
    char combuf[256];
    if(portbuf != NULL){
      for (i = 0; portbuf[i] != 0 && portbuf[i] != ':'; i++) {
      }
      if (portbuf[i] == ':') {
	port = atoi(portbuf + i + 1) + 6000;
      }
    }

    /*    printf("Input Server Addresss:>");
	  scanf("%s",&dstIP); */
    strcpy(dstIP,"127.0.0.1");
    /// gethostbyname
    /*  port = 6020;*/

    memset(&dstAddr, 0, sizeof(dstAddr));
    dstAddr.sin_port = htons(port);
    dstAddr.sin_family = AF_INET;
    dstAddr.sin_addr.s_addr = inet_addr(dstIP);
    clt_sock = socket(AF_INET, SOCK_STREAM, 0);

    printf("Trying to window server %s:%d\n",dstIP,port);
    int res = connect(clt_sock, (struct sockaddr *) &dstAddr, sizeof(dstAddr));
    if(res != 0){ // error 
      printf(" Socket Connect Error %d\n",errno);
      exit(1);
    }

    ///    printf("Now xauth list $DISPLAY | tail -1 | awk '{print $3}'");
    //printf("FP is %x\n",fp);
    sprintf(combuf,"xauth list %s/unix:%d | tail -1 | awk '{print $3}'",hostname,port-6000);
    //    sprintf(combuf,"xauth list 172.16.2.12:%d | tail -1 | awk '{print $3}'",port-6000);
    //    printf("Do '%s'\n",combuf);

    fp = popen(combuf,"r");
    fgets(sbuf,200,fp);
    printf("Get current cookie %s",sbuf);
    pclose(fp);
    for(i = 0 ; i< 12; i++) iniBuf[i]=  XinitBuf[i];
    strcpy(&(iniBuf[12]),"MIT-MAGIC-COOKIE-1");
    iniBuf[31] = 0;
    iniBuf[32] = 0;
    for(i = 0; i < 16; i++){
      char buf[3];
      buf[0]= sbuf[i*2];
      buf[1]= sbuf[i*2 + 1];
      buf[2]=0;
      iniBuf[32+i] = (unsigned char) strtol(buf, NULL, 16);
    }
    send(clt_sock,iniBuf,48,0);
    printf("Connected..\n");
  }
}

void sendcmd(char *bf){
  send(clt_sock,bf,strlen(bf)+1,0);
}



void initwin(){
  connect_sock();
  sleep(0);
  sprintf(sbuf,"clear \r\n");
  sendcmd(sbuf);
  sprintf(sbuf,"clear \r\n");
  sendcmd(sbuf);
  sprintf(sbuf,"clear \r\n");
  sendcmd(sbuf);
  sprintf(sbuf,"size %d %d \r\n",width,height);
  sendcmd(sbuf);
}

void dot(int x, int y){
  sprintf(sbuf,"dot %d %d \r\n",x,y);
  sendcmd(sbuf);
}

void text(int x, int y,char *str){
  sprintf(sbuf,"text %d %d \"%s\"\r\n",x,y,str);
  sendcmd(sbuf);
}

void g_line(int x0, int y0, int x1, int y1){
  sprintf(sbuf,"line %d %d %d %d \r\n",x0,y0,x1,y1);
  sendcmd(sbuf);
}

void g_rgb(unsigned short r, unsigned short g, unsigned short b){
  sprintf(sbuf,"color %d %d %d\r\n",r,g,b);
  sendcmd(sbuf);
}

void g_fill(int x0,int y0, int wid, int hei){
  sprintf(sbuf,"fill %d %d %d %d \r\n",x0,y0,wid,hei);
  sendcmd(sbuf);
}

void g_box(int x0, int y0, int wid, int hei){
  sprintf(sbuf,"box %d %d %d %d \r\n",x0,y0,wid,hei);
  sendcmd(sbuf);
}

void g_clear(){
  sprintf(sbuf,"clear\r\n");
  sendcmd(sbuf);
}





