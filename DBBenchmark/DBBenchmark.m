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

#ifndef NSCAssert
#define NSCAssert(condition, log) assert(condition)
#endif

#define MAX_BENCHMARKS 10

static uint64_t _activeBenchmarks[MAX_BENCHMARKS];
static NSString * const kDBBenchmarkDefaultName = @"Benchmark";

int _benchmarkCount = 0;

#pragma mark - Private -
static double _DBNanosecondsFromAbsolute(uint64_t absolute) {
    
    static char infoAvailable;
    mach_timebase_info_data_t info;
    if (!infoAvailable) {
        mach_timebase_info(&info);
        infoAvailable = 1;
    }
    
    return (absolute * info.numer / info.denom) / (1.0 * NSEC_PER_SEC);
}

static inline void _DBBenchmarkPrintFromTime(uint64_t startTime, NSString *name) {
    printf("[DBBenchmark] - %s: %0.5f sec\n", [name UTF8String], _DBNanosecondsFromAbsolute(mach_absolute_time() - startTime));
}

#pragma mark - Functions -
inline void DBBenchmarkWithBlock(NSString *name, DBBenchmarkBlock block) {
    uint64_t startTime = mach_absolute_time();
    block();
    _DBBenchmarkPrintFromTime(startTime, name);
}

inline void DBBenchmarkDefault(DBBenchmarkBlock block) {
    DBBenchmarkWithBlock(kDBBenchmarkDefaultName, block);
}

inline void DBBenchmarkStart() {
    
    NSCAssert(_benchmarkCount < MAX_BENCHMARKS, @"Maximum number of concurrent benchmarks exceeded");
    _activeBenchmarks[_benchmarkCount++] = mach_absolute_time();
}

inline void DBBenchmarkEnd(NSString *name, ...) {
    NSCAssert(_benchmarkCount > 0, @"DBBenchmarkStart must be called before calling DBBenchmarkEnd()");
    
    uint64_t startTime = _activeBenchmarks[--_benchmarkCount];
    
    va_list args;
    va_start(args, name);
    NSString *benchmarkName = [[NSString alloc] initWithFormat:name arguments:args];
    va_end(args);
    
    _DBBenchmarkPrintFromTime(startTime, benchmarkName);
    _activeBenchmarks[_benchmarkCount] = 0;
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



