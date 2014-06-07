//
//  DBBenchmark.m
//
//  Created by Dima Bart on 2013-09-09.
//  Copyright (c) 2013 Dima Bart. All rights reserved.
//

#import "DBBenchmark.h"

//#if DEBUG

static int const kDBBenchmarkMaxConcurrent = 10;
static CFAbsoluteTime _activeBenchmarks[kDBBenchmarkMaxConcurrent];
static NSString * const kDBBenchmarkDefaultName = @"Benchmark";

int _benchmarkCount = 0;

#pragma mark - Private -
static inline void _DBBenchmarkPrintFromTime(CFAbsoluteTime startTime, NSString *name) {
    printf("[DBBenchmark] - %s: %0.5f sec\n", [name UTF8String], CFAbsoluteTimeGetCurrent() - startTime);
}

#pragma mark - Functions -
inline void DBBenchmarkWithBlock(NSString *name, DBBenchmarkBlock block) {
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    block();
    _DBBenchmarkPrintFromTime(startTime, name);
}

inline void DBBenchmarkDefault(DBBenchmarkBlock block) {
    DBBenchmarkWithBlock(kDBBenchmarkDefaultName, block);
}

inline void DBBenchmarkStart() {
    NSCAssert(_benchmarkCount < kDBBenchmarkMaxConcurrent, @"Maximum number of concurrent benchmarks exceeded");
    _activeBenchmarks[_benchmarkCount++] = CFAbsoluteTimeGetCurrent();
}

inline void DBBenchmarkEnd(NSString *name, ...) {
    NSCAssert(_benchmarkCount > 0, @"DBBenchmarkStart must be called before calling DBBenchmarkEnd()");
    
    CFAbsoluteTime startTime = _activeBenchmarks[--_benchmarkCount];
    
    va_list args;
    va_start(args, name);
    NSString *benchmarkName = [[NSString alloc] initWithFormat:name arguments:args];
    va_end(args);
    
    _DBBenchmarkPrintFromTime(startTime, benchmarkName);
    _activeBenchmarks[_benchmarkCount] = 0;
}

//#endif

@implementation DBBenchmark

#pragma mark - Bench Marks -
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



