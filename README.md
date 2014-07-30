DBBenchmark
===========

An Objective-C/C framework designed for extremely simple and easy benchmarking during development.

### Block-based Benchmarks
Benchmarking with blocks can be is very easy:
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
