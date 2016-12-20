---
section: Documentation
nav-documentation: True
---

# Parallel and Concurrent Programming in Haskell: Errata

This section lists changes and corrections to Simon Marlow's excellent book
[*Parallel and Concurrent Programming in Haskell*](http://chimera.labs.oreilly.com/books/1230000000929)
due to changes in the Accelerate API since the book's publication. The book is
available for purchase from O'Rielly Media in electronic and paper formats, and
can also be viewed online for free.


## 6. GPU Programming with Accelerate

  * To run programs on the GPU, it is recommended to use the
    `accelerate-llvm-ptx` backend, rather than the (older, deprecated)
    `accelerate-cuda` backend. To use this backend, we need to use:
```haskell
import Data.Array.Accelerate.LLVM.PTX
```
    in place of:
```haskell
import Data.Array.Accelerate.CUDA
```
    Alternatively, if you do not have a CUDA capable GPU, rather than using the
    (very slow) interpreter backend you can use the `accelerate-llvm-native`
    backend for multicore CPUs, which was not available at the time of
    publication:
```haskell
import Data.Array.Accelerate.LLVM.Native
```

