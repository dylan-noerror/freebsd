#!/bin/sh

# panic: sbflush_internal: ccc 0 mb 0 mbcnt 256
# cpuid = 4
# time = 1592126385
# KDB: stack backtrace:
# db_trace_self_wrapper() at db_trace_self_wrapper+0x2b/frame 0xfffffe012b22f8d0
# vpanic() at vpanic+0x182/frame 0xfffffe012b22f920
# panic() at panic+0x43/frame 0xfffffe012b22f980
# sbrelease_internal() at sbrelease_internal+0xbd/frame 0xfffffe012b22f9a0
# solisten_proto() at solisten_proto+0xab/frame 0xfffffe012b22fa00
# sctp_listen() at sctp_listen+0x2f4/frame 0xfffffe012b22fa60
# solisten() at solisten+0x42/frame 0xfffffe012b22fa80
# kern_listen() at kern_listen+0x7c/frame 0xfffffe012b22fac0
# ia32_syscall() at ia32_syscall+0x150/frame 0xfffffe012b22fbf0
# int0x80_syscall_common() at int0x80_syscall_common+0x9c/frame 0xffffdb10
# KDB: enter: panic
# [ thread pid 93263 tid 100202 ]
# Stopped at      kdb_enter+0x37: movq    $0,0x10c5456(%rip)
# db> x/s version
# version:        FreeBSD 13.0-CURRENT #0 r362171: Sun Jun 14 09:06:12 CEST 2020
# pho@mercat1.netperf.freebsd.org:/usr/src/sys/amd64/compile/PHO
# db> 

# $FreeBSD$

[ `uname -p` != "amd64" ] && exit 0

. ../default.cfg
kldstat -v | grep -q sctp || kldload sctp.ko
cat > /tmp/syzkaller15.c <<EOF
// https://syzkaller.appspot.com/bug?id=6b9cfdc1689b0adee1c6f75f56ab034a70500d93
// autogenerated by syzkaller (https://github.com/google/syzkaller)
// Reported-by: syzbot+bca42a93f1254ca91e94@syzkaller.appspotmail.com

#define _GNU_SOURCE

#include <sys/types.h>

#include <pwd.h>
#include <setjmp.h>
#include <signal.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/endian.h>
#include <sys/syscall.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>

static unsigned long long procid;

static __thread int skip_segv;
static __thread jmp_buf segv_env;

static void segv_handler(int sig, siginfo_t* info, void* ctx __unused)
{
  uintptr_t addr = (uintptr_t)info->si_addr;
  const uintptr_t prog_start = 1 << 20;
  const uintptr_t prog_end = 100 << 20;
  if (__atomic_load_n(&skip_segv, __ATOMIC_RELAXED) &&
      (addr < prog_start || addr > prog_end)) {
    _longjmp(segv_env, 1);
  }
  exit(sig);
}

static void install_segv_handler(void)
{
  struct sigaction sa;
  memset(&sa, 0, sizeof(sa));
  sa.sa_sigaction = segv_handler;
  sa.sa_flags = SA_NODEFER | SA_SIGINFO;
  sigaction(SIGSEGV, &sa, NULL);
  sigaction(SIGBUS, &sa, NULL);
}

#define NONFAILING(...)                                                        \
  {                                                                            \
    __atomic_fetch_add(&skip_segv, 1, __ATOMIC_SEQ_CST);                       \
    if (_setjmp(segv_env) == 0) {                                              \
      __VA_ARGS__;                                                             \
    }                                                                          \
    __atomic_fetch_sub(&skip_segv, 1, __ATOMIC_SEQ_CST);                       \
  }

static void kill_and_wait(int pid, int* status)
{
  kill(pid, SIGKILL);
  while (waitpid(-1, status, 0) != pid) {
  }
}

static void sleep_ms(uint64_t ms)
{
  usleep(ms * 1000);
}

static uint64_t current_time_ms(void)
{
  struct timespec ts;
  if (clock_gettime(CLOCK_MONOTONIC, &ts))
    exit(1);
  return (uint64_t)ts.tv_sec * 1000 + (uint64_t)ts.tv_nsec / 1000000;
}

static void execute_one(void);

#define WAIT_FLAGS 0

static void loop(void)
{
  int iter;
  for (iter = 0;; iter++) {
    int pid = fork();
    if (pid < 0)
      exit(1);
    if (pid == 0) {
      execute_one();
      exit(0);
    }
    int status = 0;
    uint64_t start = current_time_ms();
    for (;;) {
      if (waitpid(-1, &status, WNOHANG | WAIT_FLAGS) == pid)
        break;
      sleep_ms(1);
      if (current_time_ms() - start < 5 * 1000)
        continue;
      kill_and_wait(pid, &status);
      break;
    }
  }
}

uint64_t r[1] = {0xffffffffffffffff};

void execute_one(void)
{
  intptr_t res = 0;
  res = syscall(SYS_socket, 0x1c, 1, 0x84);
  if (res != -1)
    r[0] = res;
  NONFAILING(*(uint8_t*)0x10000040 = 0xc8);
  NONFAILING(*(uint8_t*)0x10000041 = 0x51);
  NONFAILING(*(uint8_t*)0x10000042 = 0);
  NONFAILING(*(uint8_t*)0x10000043 = 0);
  NONFAILING(*(uint8_t*)0x10000044 = 0);
  NONFAILING(*(uint8_t*)0x10000045 = 0);
  NONFAILING(*(uint8_t*)0x10000046 = 0);
  NONFAILING(*(uint8_t*)0x10000047 = 0);
  NONFAILING(*(uint8_t*)0x10000048 = 0);
  NONFAILING(*(uint8_t*)0x10000049 = 0);
  NONFAILING(*(uint8_t*)0x1000004a = 0);
  syscall(SYS_setsockopt, (intptr_t)r[0], 0x84, 0xc, 0x10000040, 0xb);
  NONFAILING(*(uint8_t*)0x10000180 = 0x5f);
  NONFAILING(*(uint8_t*)0x10000181 = 0x1c);
  NONFAILING(*(uint16_t*)0x10000182 = htobe16(0x4e22 + procid * 4));
  NONFAILING(*(uint32_t*)0x10000184 = 0);
  NONFAILING(*(uint64_t*)0x10000188 = htobe64(0));
  NONFAILING(*(uint64_t*)0x10000190 = htobe64(1));
  NONFAILING(*(uint32_t*)0x10000198 = 0);
  syscall(SYS_connect, (intptr_t)r[0], 0x10000180, 0x1c);
  syscall(SYS_listen, (intptr_t)r[0], 7);
}
int main(void)
{
  syscall(SYS_mmap, 0x10000000, 0x1000000, 7, 0x1012, -1, 0);
  install_segv_handler();
  for (procid = 0; procid < 4; procid++) {
    if (fork() == 0) {
      loop();
    }
  }
  sleep(1000000);
  return 0;
}
EOF
mycc -o /tmp/syzkaller15 -Wall -Wextra -O0 -m32 /tmp/syzkaller15.c ||
    exit 1

(cd /tmp; ./syzkaller15) &
sleep 60
pkill -9 syzkaller15
wait

rm -f /tmp/syzkaller15 /tmp/syzkaller15.c /tmp/syzkaller15.core
exit 0
