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
7.10.x and 8.0.x, but should also work with 7.8.x. Remember which version of GHC
you install, as this will be important in the next step.


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
compiling from source be sure to build LLVM with shared library support.

Example process of installing LLVM-3.8 on Ubuntu-16.04:

  1. Retrieve the archive signature:
```sh
wget -O - http://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add -
```

  2. Add the APT package locations:
```sh
deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial main
deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-3.8 main
```

  3. Install LLVM:
```sh
apt-get install llvm-3.8-dev
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


## 3. Run an Accelerate program


## 4. Next steps


## 5. Further information

