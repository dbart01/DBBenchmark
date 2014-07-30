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

```
