//
//  DBBenchmark.m
//
//  Copyright (c) 2015 Dima Bart
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those
//  of the authors and should not be interpreted as representing official policies,
//  either expressed or implied, of the FreeBSD Project.

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
