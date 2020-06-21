#include <am.h>
#include <benchmark.h>
#include <trap.h>
#include <limits.h>

typedef struct Result {
  int pass;
  unsigned long msec;
  unsigned long instruction_cnt;
  unsigned long mem_access_instr_cnt;
  unsigned long mem_delay_cnt;
  unsigned long branch_achieved_cnt;  
  unsigned long branch_notachvd_cnt;  
} Result;

unsigned long _uptime() {
  // TODO [COD]
  //   You can use this function to access performance counter related with time or cycle.
  unsigned long *addr = (void *)0x40020000;
  unsigned long time;
  time = *addr;
  return time;
}

unsigned long _instr() {
  unsigned long *addr = (void *)0x40020008;
  unsigned long count;
  count = *addr;
  return count;
}

unsigned long _mem_acc_instr() {
  unsigned long *addr = (void *)0x40021000;
  unsigned long count;
  count = *addr;
  return count;
}

unsigned long _mem_delay() {
  unsigned long *addr = (void *)0x40021008;
  unsigned long count;
  count = *addr;
  return count;
}

unsigned long _branch_achvd() {
  unsigned long *addr = (void *)0x40022000;
  unsigned long count;
  count = *addr;
  return count;
}

unsigned long _branch_notachvd() {
  unsigned long *addr = (void *)0x40022008;
  unsigned long count;
  count = *addr;
  return count;
}



static void bench_prepare(Result *res) {
  // TODO [COD]
  //   Add preprocess code, record performance counters' initial states.
  //   You can communicate between bench_prepare() and bench_done() through
  //   static variables or add additional fields in `struct Result`
  res->msec = _uptime();
  res->instruction_cnt = _instr();
  res->mem_access_instr_cnt = _mem_acc_instr();
  res->mem_delay_cnt = _mem_delay();
  res->branch_achieved_cnt = _branch_achvd();
  res->branch_notachvd_cnt = _branch_notachvd();  
}

static void bench_done(Result *res) {
  // TODO [COD]
  //  Add postprocess code, record performance counters' current states.
  res->msec = _uptime() - res->msec;
  res->instruction_cnt = _instr() - res->instruction_cnt;
  res->mem_access_instr_cnt = _mem_acc_instr() - res->mem_access_instr_cnt;
  res->mem_delay_cnt = _mem_delay() - res->mem_delay_cnt;
  res->branch_achieved_cnt = _branch_achvd() - res->branch_achieved_cnt;
  res->branch_notachvd_cnt = _branch_notachvd() - res->branch_notachvd_cnt; 
}


Benchmark *current;
Setting *setting;

static char *start;

#define ARR_SIZE(a) (sizeof((a)) / sizeof((a)[0]))

// The benchmark list

#define ENTRY(_name, _sname, _s1, _s2, _desc) \
  { .prepare = bench_##_name##_prepare, \
    .run = bench_##_name##_run, \
    .validate = bench_##_name##_validate, \
    .name = _sname, \
    .desc = _desc, \
    .settings = {_s1, _s2}, },

Benchmark benchmarks[] = {
  BENCHMARK_LIST(ENTRY)
};

extern char _heap_start[];
extern char _heap_end[];
_Area _heap = {
  .start = _heap_start,
  .end = _heap_end,
};

static const char *bench_check(Benchmark *bench) {
  unsigned long freesp = (unsigned long)_heap.end - (unsigned long)_heap.start;
  if (freesp < setting->mlim) {
    return "(insufficient memory)";
  }
  return NULL;
}

void run_once(Benchmark *b, Result *res) {
  bench_reset();       // reset malloc state
  current->prepare();  // call bechmark's prepare function
  bench_prepare(res);  // clean everything, start timer
  current->run();      // run it
  bench_done(res);     // collect results
  res->pass = current->validate();
}

int main() {
  int pass = 1;

  _Static_assert(ARR_SIZE(benchmarks) > 0, "non benchmark");

  for (int i = 0; i < ARR_SIZE(benchmarks); i ++) {
    Benchmark *bench = &benchmarks[i];
    current = bench;
    setting = &bench->settings[SETTING];
    const char *msg = bench_check(bench);
    printk("[%s] %s: ", bench->name, bench->desc);
    if (msg != NULL) {
      printk("Ignored %s\n", msg);
    } else {
      unsigned long msec = ULONG_MAX;
      unsigned long instruction_cnt = ULONG_MAX;
      unsigned long mem_access_instr_cnt = ULONG_MAX;
      unsigned long mem_delay_cnt = ULONG_MAX;
      unsigned long branch_achieved_cnt = ULONG_MAX;
      unsigned long branch_notachvd_cnt = ULONG_MAX;
      int succ = 1;
      for (int i = 0; i < REPEAT; i ++) {
        Result res;
        run_once(bench, &res);
        printk(res.pass ? "*" : "X");
        succ &= res.pass;
        if (res.msec < msec) msec = res.msec;
        if (res.instruction_cnt < instruction_cnt) instruction_cnt = res.instruction_cnt;
        if (res.mem_access_instr_cnt < mem_access_instr_cnt) mem_access_instr_cnt = res.mem_access_instr_cnt;
        if (res.mem_delay_cnt < mem_delay_cnt) mem_delay_cnt = res.mem_delay_cnt;
        if (res.branch_achieved_cnt < branch_achieved_cnt) branch_achieved_cnt = res.branch_achieved_cnt;
        if (res.branch_notachvd_cnt < branch_notachvd_cnt) branch_notachvd_cnt = res.branch_notachvd_cnt;
      }

      if (succ) printk(" Passed.\n");
      else printk(" Failed.\n");

      pass &= succ;

      // TODO [COD]
      //   A benchmark is finished here, you can use printk to output some informantion.
      //   `msec' is intended indicate the time (or cycle),
      //   you can ignore according to your performance counters semantics.
      printk("Performance:\n");
      printk("\tCycle Count:                 %d\n",msec);
      printk("\tInstruction_finished Count:  %d\n",instruction_cnt);
      printk("\tInstruction_mem_acc Count:   %d\n",mem_access_instr_cnt);
      printk("\tMem_access Delay Count:      %d\n",mem_delay_cnt);
      printk("\tBranch_achieved Count:       %d\n",branch_achieved_cnt);
      printk("\tBranch_not_achieved Count:   %d\n",branch_notachvd_cnt);
    }
  }

  printk("benchmark finished\n");

  if(pass)
    hit_good_trap();
  else
    nemu_assert(0);

  return 0;
}

// Library


void* bench_alloc(size_t size) {
  if ((uintptr_t)start % 16 != 0) {
    start = start + 16 - ((uintptr_t)start % 16);
  }
  char *old = start;
  start += size;
  assert((uintptr_t)_heap.start <= (uintptr_t)start && (uintptr_t)start < (uintptr_t)_heap.end);
  for (char *p = old; p != start; p ++) *p = '\0';
  assert((uintptr_t)start - (uintptr_t)_heap.start <= setting->mlim);
  return old;
}

void bench_free(void *ptr) {
}

void bench_reset() {
  start = (char*)_heap.start;
}

static int32_t seed = 1;

void bench_srand(int32_t _seed) {
  seed = _seed & 0x7fff;
}

int32_t bench_rand() {
  seed = (mmul_u(seed , (int32_t)214013L) + (int32_t)2531011L);
  return (seed >> 16) & 0x7fff;
}

// FNV hash
uint32_t checksum(void *start, void *end) {
  const int32_t x = 16777619;
  int32_t hash = 2166136261u;
  for (uint8_t *p = (uint8_t*)start; p + 4 < (uint8_t*)end; p += 4) {
    int32_t h1 = hash;
    for (int i = 0; i < 4; i ++) {
      h1 = mmul_u((h1 ^ p[i]) , x);
    }
    hash = h1;
  }
  hash += hash << 13;
  hash ^= hash >> 7;
  hash += hash << 3;
  hash ^= hash >> 17;
  hash += hash << 5;
  return hash;
}

