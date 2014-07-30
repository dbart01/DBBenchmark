//
//  DBBenchmark.m
//
//  Created by Dima Bart on 2013-09-09.
//  Copyright (c) 2013 Dima Bart. All rights reserved.
//

#import "DBBenchmark.h"

#include <mach/mach_time.h>
#include <string.h>
#include <stdio.h>
#include <libkern/OSAtomic.h>

#ifndef NSCAssert
#define NSCAssert(condition, log) assert(condition)
#endif

#define MAX_BENCHMARKS 10

static OSSpinLock _lock = OS_SPINLOCK_INIT;
static CFAbsoluteTime _activeBenchmarks[MAX_BENCHMARKS];
static NSString * const kDBBenchmarkDefaultName = @"Benchmark";

int _benchmarkCount = 0;

#pragma mark - Private -
static inline void _DBBenchmarkPrintFromTime(CFAbsoluteTime startTime, NSString *name) {
    printf("[DBBenchmark] - %s: %0.5f sec\n", [name UTF8String], CFAbsoluteTimeGetCurrent() - startTime);
}

#pragma mark - Functions -
inline void DBBenchmarkWithBlock(NSString *name, DBBenchmarkBlock block) {
    OSSpinLockLock(&_lock);
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    block();
    _DBBenchmarkPrintFromTime(startTime, name);
    OSSpinLockUnlock(&_lock);
}

inline void DBBenchmarkDefault(DBBenchmarkBlock block) {
    DBBenchmarkWithBlock(kDBBenchmarkDefaultName, block);
}

inline void DBBenchmarkStart() {
    OSSpinLockLock(&_lock);
    NSCAssert(_benchmarkCount < MAX_BENCHMARKS, @"Maximum number of concurrent benchmarks exceeded");
    _activeBenchmarks[_benchmarkCount++] = CFAbsoluteTimeGetCurrent();
    OSSpinLockUnlock(&_lock);
}

inline void DBBenchmarkEnd(NSString *name, ...) {
    OSSpinLockLock(&_lock);
    NSCAssert(_benchmarkCount > 0, @"DBBenchmarkStart must be called before calling DBBenchmarkEnd()");
    
    CFAbsoluteTime startTime = _activeBenchmarks[--_benchmarkCount];
    
    va_list args;
    va_start(args, name);
    NSString *benchmarkName = [[NSString alloc] initWithFormat:name arguments:args];
    va_end(args);
    
    _DBBenchmarkPrintFromTime(startTime, benchmarkName);
    _activeBenchmarks[_benchmarkCount] = 0;
    OSSpinLockUnlock(&_lock);
}


#pragma mark - DBBenchmark -
@implementation DBBenchmark

+ (void)benchmarkName:(NSString *)name withBlock:(DBBenchmarkBlock)block {
    DBBenchmarkWithBlock(name, block);
}

+ (void)benchmark:(DBBenchmarkBlock)block {
    DBBenchmarkWithBlock(kDBBenchmarkDefaultName, block);
}

+ (void)start {
    DBBenchmarkStart();
}

+ (void)end:(NSString *)name, ... {
    
    va_list args;
    va_start(args, name);
    NSString *benchmarkName = [[NSString alloc] initWithFormat:name arguments:args];
    va_end(args);
    
    DBBenchmarkEnd(benchmarkName);
}

+ (void)end {
    DBBenchmarkEnd(kDBBenchmarkDefaultName);
}

@end



