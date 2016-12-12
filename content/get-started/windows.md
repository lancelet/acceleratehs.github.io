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

Selected operating system: **Windows**

<a href="/get-started/macos" title="macOS" class="os-logo os-faded">
  <img src="/media/apple-logo.svg">
</a>
<a href="/get-started/linux" title="Linux" class="os-logo os-faded">
  <img src="/media/linux-logo.svg">
</a>
<a href="/get-started/windows" title="Windows" class="os-logo">
  <img src="/media/windows-logo.svg">
</a>


Oh no! We currently do not have any Windows machines available to test
Accelerate on. If you try installing Accelerate on Windows, please let us know
on the [mailing list](http://groups.google.com/group/accelerate-haskell) or
[issue tracker](https://github.com/AccelerateHS/accelerate/issues) (preferred)
how you went. Especially if you are successful, please let us know the procedure
you used so that we can update the instructions to help others (or consider
submitting a [pull
request!](https://github.com/AccelerateHS/acceleratehs.github.io)). Thanks in
advance!

