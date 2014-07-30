DBBenchmark
===========

An Objective-C/C framework designed for extremely simple and easy benchmarking during development. Easily integrate into your project using the static library DBBenchmark.framework and import in your source:
```objc
#import <DBBenchmark/DBBenchmark.h>
```

### Block-based Benchmarks
Benchmarking with blocks is very easy. You can even customize the output name:
```objc
[DBBenchmark benchmark:^{
  for (int i = 0; i < 1000000; ++i) {
    // Perform lots of work
  }
}];
// Benchmark: 0.0043 seconds

// You can even add a name to display when logging
[DBBenchmark benchmarkName:@"Testing Loop" withBlock:^{
  for (int i = 0; i < 1000000; ++i) {
    // Perform lots of work
  }
}];
// Testing Loop: 0.0043 seconds
```

### Regular Benchmarks
Sometimes blocks make life more difficult and its just easier to add two line of code. Using this method, the name for the benchmark is given when you call <code>[DBBenchmark end:]</code>.
```objc
[DBBenchmark start];
for (int i = 0; i < 1000000; ++i) {
  // Perform lots of work
}
[DBBenchmark end:@"Testing Loop"];
// Testing Loop: 0.0043 seconds
```

### C Function Benchmarks
The advantage of using C functions is that there's not need to strip out all the benchmarking code before release. The functions are automatically discarded via the pre-processor for all release builds. Use them like so:
```objc
DBBenchmarkStart();
for (int i = 0; i < 1000000; ++i) {
  // Perform lots of work
}
DBBenchmarkEnd(@"Testing a Loop %d times", 1000000);
// Testing a Loop 1000000 times: 0.0043 seconds
```
The beauty of <code>DBBenchmarkEnd()</code> is that it takes a variable number of arguments so you can pass them in just like <code>NSLog()</code>.

### Nesting Benchmarks
Any of the benchmarking methods above can be nested and are thread-safe. So this is perfectly acceptable:
```objc
DBBenchmarkStart();
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    for (int i = 0; i < 1000000; ++i) {
        
        DBBenchmarkStart();
        // Perform a unit of work
        DBBenchmarkEnd(@"Inner Benchmark");
    }
    DBBenchmarkEnd(@"Testing a Loop %d times", 1000000);
});
```
However, be careful not to start concurrent benchmarks because they will likely result in wonky data due to some benchmarks ending the wrong benchmarks.
