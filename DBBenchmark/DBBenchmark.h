//
//  DBBenchmark.h
//
//  Created by Dima Bart on 2013-09-09.
//  Copyright (c) 2013 Dima Bart. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DBBenchmarkBlock)(void);

@interface DBBenchmark : NSObject

+ (void)benchmarkName:(NSString *)name withBlock:(DBBenchmarkBlock)block;
+ (void)benchmark:(DBBenchmarkBlock)block;

+ (void)start;
+ (void)end:(NSString *)name, ...;
+ (void)end;

@end

#ifdef __cplusplus
#define DB_EXTERN extern "C"
#else
#define DB_EXTERN extern
#endif

#if !DEBUG

#define DBBenchmarkWithBlock(name, block)
#define DBBenchmarkDefault(block)
#define DBBenchmarkStart()
#define DBBenchmarkEnd(name, ...)

#else

DB_EXTERN void DBBenchmarkWithBlock(NSString *name, DBBenchmarkBlock block) __attribute__((always_inline));
DB_EXTERN void DBBenchmarkDefault(DBBenchmarkBlock block) __attribute__((always_inline));
DB_EXTERN void DBBenchmarkStart() __attribute__((always_inline));
DB_EXTERN void DBBenchmarkEnd(NSString *name, ...) __attribute__((always_inline));

#endif