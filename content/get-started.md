---
section: "Get Started"
nav-get-started: True
---

Get Started
===========

_Accelerate_ is a language for data-parallel array computations embedded within
the programming language [_Haskell_](https://www.haskell.org). More
specifically, it is a deeply embedded language. This means that when you write
programs with Accelerate, you are writing a Haskell program using operations
from the Accelerate library, but the method by which the program runs is
different from a conventional Haskell program. A program written in Accelerate
is actually a Haskell program that generates, optimises, and compiles code for
the GPU or CPU on-the-fly at program runtime.

To get started you will need to set up a Haskell environment as well as a few
external libraries.

## 1. Setup Haskell & LLVM

Select your operating system:

<a href="/get-started/macos" title="macOS" class="os-logo os-choose">
  <img src="/media/apple-logo.svg">
</a>
<a href="/get-started/linux" title="Linux" class="os-logo os-choose">
  <img src="/media/linux-logo.svg">
</a>
<a href="/get-started/windows" title="Windows" class="os-logo os-choose">
  <img src="/media/windows-logo.svg">
</a>


## 2. Install Accelerate

We can now install the core Accelerate library:
```sh
cabal install accelerate
```

This is sufficient to write programs in Accelerate as well as execute them using
the included interpreter backend.[^1] For good performance however we also need
to install one (or both) of the LLVM backends, which will compile Accelerate
programs to native code.

Install a version of the `llvm-general` package suitable for the version of LLVM
installed in step [1.2](#llvm).[^2] The first two numbers of the version of LLVM
and the `llvm-general` package must match. We must also install with shared
library support so that we can use `llvm-general` from within `ghci` (and
Template Haskell). Continuing the example above where we installed LLVM-3.8:
```sh
cabal install llvm-general -fshared-llvm --constraint="llvm-general==3.8.*"
```

Install the Accelerate LLVM backend for multicore CPUs:
```sh
cabal install accelerate-llvm-native
```

(Optional) If you have a CUDA capable GPU and installed the CUDA toolkit in step
[1.3](#cuda-optional), you can also install the Accelerate backend for
NVIDIA GPUs:
```sh
cabal install accelerate-llvm-ptx
```


## 3. Run an Accelerate program

Copy the following content into a file called `Dotp.hs`. This simple example
computes the dot product of two vectors of single-precision floating-point
numbers. If you installed the GPU backend in step [2](#install-accelerate), you
can uncomment the third line (delete the leading `--`) to enable both the CPU
and GPU backends.

```haskell
import Data.Array.Accelerate              as A
import Data.Array.Accelerate.LLVM.Native  as CPU
-- import Data.Array.Accelerate.LLVM.PTX     as GPU

dotp :: Acc (Vector Float) -> Acc (Vector Float) -> Acc (Scalar Float)
dotp xs ys = A.fold (+) 0 (A.zipWith (*) xs ys)
```

Open up a terminal and load the file into the Haskell interpreter with `ghci
Dotp.hs`.

  1. Create some arrays to feed into the computation. See the
     [documentation](/documentation.html) for more information, as well as
     additional ways to get data into the program.
```
ghci> let xs = fromList (Z:.10) [0..]   :: Vector Float
ghci> let ys = fromList (Z:.10) [1,3..] :: Vector Float
```

  2. Run the computation:
```
ghci> CPU.run $ dotp (use xs) (use ys)
Scalar Z [615.0]
```
     This will convert the Accelerate program into LLVM code, optimise, compile,
     and execute it on the CPU. If your computer has multiple CPU cores, you can
     execute using multiple CPU cores by launching `ghci` (or running a compiled
     program) with the additional command line options `+RTS -Nx -RTS`, to use
     _x_ CPU cores (or omit _x_ to use as many cores as your machine has).

  3. (Optional) If you installed the `accelerate-llvm-ptx` backend, you can also
     execute the computation on the GPU simply by:
```
ghci> GPU.run $ dotp (use xs) (use ys)
Scalar Z [615.0]
```
     This will instead convert the Accelerate program into LLVM code suitable
     for the GPU, optimise, compile, and execute it on the GPU, as well as copy
     the input arrays into GPU memory and copy the result back into CPU memory.


## 4. Next steps


## 5. Further information




  [^1]: Although the core `accelerate` package includes an interpreter that can be
        used to run Accelerate programs, its performance is fairly poor as it is
        designed as a reference implementation of the language semantics, rather
        than for performance.

  [^2]: This constraint is also why we currently can not support LLVM-3.6,
        LLVM-3.7, or LLVM-3.5 on GHC-8.0; `llvm-general` is unfortunately not
        currently available for those targets.

