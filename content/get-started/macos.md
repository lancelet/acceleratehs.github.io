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

Selected operating system: **macOS**

<a href="/get-started/macos" title="macOS" class="os-logo">
  <img src="/media/apple-logo.svg">
</a>
<a href="/get-started/linux" title="Linux" class="os-logo os-faded">
  <img src="/media/linux-logo.svg">
</a>
<a href="/get-started/windows" title="Windows" class="os-logo os-faded">
  <img src="/media/windows-logo.svg">
</a>

### 1.1 GHC

Download and install [GHC](https://www.haskell.org/platform/mac.html). The
minimal binary distribution contains GHC-8.0 plus build tools such as `cabal`,
and is the generally recommended option over the full install (which
additionally includes some pre-installed libraries). Instructions for installing
via the [Homebrew](http://brew.sh) or [MacPorts](https://www.macports.org)
package managers are also available on that page.


### 1.2 LLVM

Executing an Accelerate program differs from that of regular Haskell programs.
Programs written in Accelerate require both the Accelerate library, which
contains the operations of the language we use to write programs, as well as a
(or several) backend(s) which will compile and execute the program for a
particular target architecture, such as CPUs or GPUs.

The two primary Accelerate backends are currently based on
[LLVM](http://llvm.org), a mature optimising compiler targeting several
architectures. LLVM is available through both the Homebrew and MacPorts package
managers, or can be compiled manually from the source releases found
[here](http://llvm.org/releases/download.html). If compiling from source be sure
to build LLVM with shared library support.

Example of installing LLVM-3.8 via [Homebrew](http://brew.sh):

```sh
brew install libffi
brew install homebrew/versions/llvm38 --all-targets
```

The LLVM-based Accelerate packages are currently tested with LLVM versions 3.5,
3.8, and 3.9. However, LLVM-3.5 is currently not compatible with GHC-8.0. Please
contact us if this is a problem for you.


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


## 4. Next steps


## 5. Further information




  [^1]: Although the core `accelerate` package includes an interpreter that can be
        used to run Accelerate programs, its performance is fairly poor as it is
        designed as a reference implementation of the language semantics, rather
        than for performance.

  [^2]: This constraint is also why we currently can not support LLVM-3.6,
        LLVM-3.7, or LLVM-3.5 on GHC-8.0; `llvm-general` is unfortunately not
        currently available for those targets.

