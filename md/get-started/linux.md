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

Selected operating system: **Linux**

<a href="/get-started/macos" title="macOS" class="os-logo os-faded">
  <img src="/media/apple-logo.svg">
</a>
<a href="/get-started/linux" title="Linux" class="os-logo">
  <img src="/media/linux-logo.svg">
</a>
<a href="/get-started/windows" title="Windows" class="os-logo os-faded">
  <img src="/media/windows-logo.svg">
</a>

### 1.1 GHC

Download and install [GHC](https://www.haskell.org/downloads/linux). Binary
package-based installers are available for a number of Linux distributions, as
described on the linked site. Accelerate is currently tested with GHC version
8.0.x and 7.10.x, but should also work with 7.8.x.


### 1.2 LLVM

Executing an Accelerate program differs from that of regular Haskell programs.
Programs written in Accelerate require both the Accelerate library, which
contains the operations of the language we use to write programs, as well as a
(or several) backend(s) which will compile and execute the program for a
particular target architecture, such as CPUs or GPUs.

The two primary Accelerate backends are currently based on
[LLVM](http://llvm.org), a mature optimising compiler targeting several
architectures. Binary distributions of LLVM are available for Debian and Ubuntu
systems at [apt.llvm.org](http://apt.llvm.org), or can be compiled manually from
the source releases found [here](http://llvm.org/releases/download.html). If
compiling from source be sure to build LLVM with the `libLLVM` shared
library.[^2]

Example process of installing LLVM-4.0 on Ubuntu-16.04:

  1. Retrieve the archive signature:
```sh
wget -O - http://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add -
```

  2. Add the APT package locations:
```sh
deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial main
deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-4.0 main
```

  3. Install LLVM:
```sh
apt-get install llvm-4.0-dev
```


### 1.3 CUDA (optional)

If you have a CUDA capable NVIDIA GPU (see the [list of supported
devices](https://en.wikipedia.org/wiki/CUDA#GPUs_supported)) and would like to
run Accelerate programs on the GPU, you will need to download and install the
CUDA toolkit available [here](https://developer.nvidia.com/cuda-downloads).


## 2. Install Accelerate

We can now install the core Accelerate library:
```sh
cabal install accelerate
```

This will install the current stable release of Accelerate from
[Hackage](https://hackage.haskell.org). If you would like to instead install the
latest in-development version, see how to [install from
GitHub](/get-started/install-from-github.html).

This is sufficient to write programs in Accelerate as well as execute them using
the included interpreter backend.[^1] For good performance however we also need
to install one (or both) of the LLVM backends, which will compile Accelerate
programs to native code.

Install a version of the `llvm-hs` package suitable for the version of LLVM
installed in step [1.2](#llvm). The first two numbers of the version of LLVM
and the `llvm-hs` package must match. We must also install with shared
library support so that we can use `llvm-hs` from within `ghci` and
Template Haskell. Continuing the example above where we installed LLVM-4.0:
```sh
cabal install llvm-hs -fshared-llvm --constraint="llvm-hs==4.0.*"
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

Congratulations, you are set up to use Accelerate! Now you are ready to:

  * [Learn more about the Accelerate language](/documentation.html)

  * [Browse libraries that you can use in your projects](/libraries.html)

  * [Check out some example programs](/examples.html)



  [^1]: Although the core `accelerate` package includes an interpreter that can be
        used to run Accelerate programs, its performance is fairly poor as it is
        designed as a reference implementation of the language semantics, rather
        than for performance.

  [^2]: Include the build options `-DLLVM_BUILD_LLVM_DYLIB=True` and
        `-DLLVM_LINK_LLVM_DYLIB=True`.

