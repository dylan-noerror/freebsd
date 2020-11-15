#!/bin/sh

# panic: to_ticks == 0 for timer type 2
# cpuid = 1
# time = 1585113958
# KDB: stack backtrace:
# db_trace_self_wrapper() at db_trace_self_wrapper+0x47/frame 0xfffffe0024a54420
# vpanic() at vpanic+0x1c7/frame 0xfffffe0024a54480
# panic() at panic+0x43/frame 0xfffffe0024a544e0
# sctp_timer_start() at sctp_timer_start+0xc7f/frame 0xfffffe0024a54540
# sctp_send_initiate() at sctp_send_initiate+0x10b/frame 0xfffffe0024a545d0
# sctp_lower_sosend() at sctp_lower_sosend+0x3f54/frame 0xfffffe0024a547b0
# sctp_sosend() at sctp_sosend+0x501/frame 0xfffffe0024a548e0
# sosend() at sosend+0xc6/frame 0xfffffe0024a54950
# kern_sendit() at kern_sendit+0x33d/frame 0xfffffe0024a54a00
# sendit() at sendit+0x224/frame 0xfffffe0024a54a60
# sys_sendto() at sys_sendto+0x5c/frame 0xfffffe0024a54ac0
# amd64_syscall() at amd64_syscall+0x2f4/frame 0xfffffe0024a54bf0
# fast_syscall_common() at fast_syscall_common+0x101/frame 0xfffffe0024a54bf0

# $FreeBSD$

# Fixed by r359405

[ `uname -p` = "i386" ] && exit 0

. ../default.cfg
kldstat -v | grep -q sctp || kldload sctp.ko
cat > /tmp/syzkaller6.c <<EOF
// https://syzkaller.appspot.com/bug?id=86fc212419e315473f7db833b9c835be21f17029
// autogenerated by syzkaller (https://github.com/google/syzkaller)

#define _GNU_SOURCE

#include <pwd.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/endian.h>
#include <sys/syscall.h>
#include <unistd.h>

uint64_t r[1] = {0xffffffffffffffff};

int main(void)
{
  syscall(SYS_mmap, 0x20000000ul, 0x1000000ul, 3ul, 0x1012ul, -1, 0ul);
  intptr_t res = 0;
  res = syscall(SYS_socket, 0x1cul, 5ul, 0x84);
  if (res != -1)
    r[0] = res;
  *(uint32_t*)0x20000200 = 0;
  *(uint32_t*)0x20000204 = 0xfffffff9;
  *(uint32_t*)0x20000208 = 0xfffffffb;
  *(uint32_t*)0x2000020c = 0;
  syscall(SYS_setsockopt, r[0], 0x84, 1, 0x20000200ul, 0x39eul);
  memcpy((void*)0x20000040, "\x11", 1);
  *(uint8_t*)0x20000100 = 0x10;
  *(uint8_t*)0x20000101 = 2;
  *(uint16_t*)0x20000102 = htobe16(0x4e21);
  *(uint8_t*)0x20000104 = 0xac;
  *(uint8_t*)0x20000105 = 0x14;
  *(uint8_t*)0x20000106 = 0;
  *(uint8_t*)0x20000107 = 0xbb;
  *(uint8_t*)0x20000108 = 0;
  *(uint8_t*)0x20000109 = 0;
  *(uint8_t*)0x2000010a = 0;
  *(uint8_t*)0x2000010b = 0;
  *(uint8_t*)0x2000010c = 0;
  *(uint8_t*)0x2000010d = 0;
  *(uint8_t*)0x2000010e = 0;
  *(uint8_t*)0x2000010f = 0;
  syscall(SYS_sendto, r[0], 0x20000040ul, 1ul, 0ul, 0x20000100ul, 0x10ul);
  return 0;
}
EOF
mycc -o /tmp/syzkaller6 -Wall -Wextra -O2 /tmp/syzkaller6.c -lpthread ||
    exit 1

(cd /tmp; ./syzkaller6)

rm /tmp/syzkaller6 /tmp/syzkaller6.c
exit 0
