---
section: Publications
nav-publications: True
---

Publications
============

If you use Accelerate for academic research, you are encouraged (though
certainly not required) to cite the following papers, which explain various
aspects of the system.

Accelerate is primarily developed by academics, so citations matter a lot to us.
As an added benefit, you increase Accelerate's exposure and potential user (and
developer!) base, which is a benefit to all users of Accelerate. Thanks in
advance!

In reverse chronological order:


### Type-safe Runtime Code Generation: Accelerate to LLVM

Trevor L. McDonell, Manuel M. T. Chakravarty, Vinod Grover, and Ryan R. Newton.

In [_Haskell '15: The 8th ACM SIGPLAN Symposium on Haskell_](https://www.haskell.org/haskell-symposium/2015/), ACM, 2015.

**Abstract:**

Embedded languages are often compiled at application runtime; thus, _embedded
compile-time errors_ become _application runtime errors_. We argue that advanced
type system features, such as GADTs and type families, play a crucial role in
minimising such runtime errors. Specifically, a rigorous type discipline reduces
run- time errors due to bugs in both embedded language applications and the
implementation of the embedded language compiler itself.

In this paper, we focus on the safety guarantees achieved by type preserving
approach by creating a new type-safe interface to the industrial-strength LLVM
are able to preserve types from the source language down to a low-level register
compilation. We discuss the compilation pipeline of _Accelerate_, a
compiler infrastructure, which we used to build two new Accelerate backends that
high-performance array language targeting both multicore CPUs and GPUs, where we
language in SSA form. Specifically, we demonstrate the practicability of our
show competitive runtimes on a set of benchmarks across both CPUs and GPUs.

 - [PDF](https://github.com/AccelerateHS/acceleratehs.github.io/raw/master/papers/acc-llvm-haskell2015.pdf) (12 pages)
 - [video](https://www.youtube.com/watch?v=snXhXA5noVc) (22 mins)
 - [slides](https://speakerdeck.com/tmcdonell/type-safe-runtime-code-generation-accelerate-to-llvm)
 - [bibtex](https://github.com/AccelerateHS/acceleratehs.github.io/raw/master/papers/acc-llvm-haskell2015.bib)


### Functional Array Streams

Frederik M. Madsen, Robert Clifton-Everest, Manuel M. T. Chakravarty, and Gabriele Keller

In [_FHPC '15: The 4th ACM SIGPLAN Workshop on Functional High-Performance Computing_](https://sites.google.com/site/fhpcworkshops/fhpc-2015), ACM, 2015.

**Abstract:**

Regular array languages for high performance computing based on aggregate
operations provide a convenient parallel programming model, which enables the
generation of efficient code for SIMD architectures, such as GPUs. However, the
data sets that can be processed with current implementations are severely
constrained by the limited amount of main memory available in these
architectures.

In this paper, we propose an extension of the embedded array language Accelerate
with a notion of sequences, resulting in a two level hierarchy which allows the
programmer to specify a partitioning strategy which facilitates automatic
resource allocation. Depending on the available memory, the runtime system
processes the overall data set in streams of chunks appropriate to the hardware
parameters.

In this paper, we present the language design for the sequence operations, as
well as the compilation and runtime support, and demonstrate with a set of
benchmarks the feasibility of this approach.

 - [PDF](https://github.com/AccelerateHS/acceleratehs.github.io/raw/master/papers/acc-seq-fhpc2015.pdf) (12 pages)
 - [bibtex](https://github.com/AccelerateHS/acceleratehs.github.io/raw/master/papers/acc-seq-fhpc2015.bib)


### Converting Data-Parallelism to Tast-Parallelism by Rewrites

Bo Joel Svensson, Michael Vollmer, Eric Holk, Trevor L. McDonell, and Ryan R. Newton

In [_FHPC '15: The 4th ACM SIGPLAN Workshop on Functional High-Performance Computing_](https://sites.google.com/site/fhpcworkshops/fhpc-2015), ACM, 2015.

**Abstract:**

High-level domain-specific languages for array processing on the GPU are
increasingly common, but they typically only run on a single GPU. As
computational power is distributed across more devices, languages must target
_multiple_ devices simultaneously. To this end, we present a compositional
translation that fissions data- parallel programs in the _Accelerate_ language,
allowing subsequent compiler and runtime stages to map computations onto
multiple devices for improved performance—even programs that begin as a single
data-parallel kernel.

 - [PDF](https://github.com/AccelerateHS/acceleratehs.github.io/raw/master/papers/acc-multidev-fhpc2015.pdf) (12 pages)
 - [bibtex](https://github.com/AccelerateHS/acceleratehs.github.io/raw/master/papers/acc-multidev-fhpc2015.bib)


### Embedding Foreign Code

Robert Clifton-Everest, Trevor L. McDonell, Manuel M. T. Chakravarty, and Gabriele Keller.

In [_PADL '14: The 16th International Symposium on Practical Aspects of Declarative Languages_](http://www.ist.unomaha.edu/padl2014/), Springer-Verlag, LNCS, 2014.

**Abstract:**

Special purpose embedded languages facilitate generating high-performance code
from purely functional high-level code; for example, we want to program highly
parallel GPUs without the usual high barrier to entry and the time-consuming
development process. We previously demonstrated the feasibility of a
skeleton-based, generative approach to compiling such embedded languages.

In this paper, we (a) describe our solution to some of the practical problems
with skeleton-based code generation and (b) introduce our approach to enabling
interoperability with native code. In particular, we show, in the context of a
functional embedded language for GPU programming, how template meta programming
simplifies code generation and optimisation. Furthermore, we present our design
for a foreign function interface for an embedded language.

 - [PDF](https://github.com/AccelerateHS/acceleratehs.github.io/raw/master/papers/acc-ffi-padl2014.pdf) (16 pages)
 - [bibtex](https://github.com/AccelerateHS/acceleratehs.github.io/raw/master/papers/acc-ffi-padl2014.bib)


### Optimising Purely Functional GPU Programs

Trevor L. McDonell, Manuel M. T. Chakravarty, Gabriele Keller, and Ben Lippmeier.

In [_ICFP '13: The 18th ACM SIGPLAN International Conference on Functional Programming_](http://www.icfpconference.org/icfp2013/), ACM, 2013.

**Abstract:**

Purely functional, embedded array programs are a good match for SIMD hardware,
such as GPUs. However, the naive compilation of such programs quickly leads to
both code explosion and an excessive use of intermediate data structures. The
resulting slow-down is not acceptable on target hardware that is usually chosen
to achieve high performance.

In this paper, we discuss two optimisation techniques, _sharing recovery_ and
_array fusion_, that tackle code explosion and eliminate superfluous
intermediate structures. Both techniques are well known from other contexts, but
they present unique challenges for an embedded language compiled for execution
on a GPU. We present novel methods for implementing sharing recovery and array
fusion, and demonstrate their effectiveness on a set of benchmarks.

 - [PDF](https://github.com/AccelerateHS/acceleratehs.github.io/raw/master/papers/acc-optim-icfp2013.pdf) (12 pages)
 - [slides](https://speakerdeck.com/tmcdonell/optimising-purely-functional-gpu-programs)
 - [bibtex](https://github.com/AccelerateHS/acceleratehs.github.io/raw/master/papers/acc-optim-icfp2013.bib)


### Accelerating Haskell Array Codes with Multicore GPUs

Manuel M. T. Chakravarty, Gabriele Keller, Sean Lee, Trevor L. McDonell, and Vinod Grover.

In [_DAMP '11: Declarative Aspects of Multicore Programming_](http://damp2011.cs.uchicago.edu/), ACM, 2011.

**Abstract:**

Current GPUs are massively parallel multicore processors optimised for workloads
with a large degree of SIMD parallelism. Good performance requires highly
idiomatic programs, whose development is work intensive and requires expert
knowledge.

To raise the level of abstraction, we propose a domain-specific high-level
language of array computations that captures appropriate idioms in the form of
collective array operations. We embed this purely functional array language in
Haskell with an online code generator for NVIDIA's CUDA GPGPU programming
environment. We regard the embedded language's collective array operations as
algorithmic skeletons; our code generator instantiates CUDA implementations of
those skeletons to execute embedded array programs.

This paper outlines our embedding in Haskell, details the design and
implementation of the dynamic code generator, and reports on initial benchmark
results. These results suggest that we can compete with moderately optimised
native CUDA code, while enabling much simpler source programs.

 - [PDF](https://github.com/AccelerateHS/acceleratehs.github.io/raw/master/papers/acc-cuda-damp2011.pdf) (12 pages)
 - [bibtex](https://github.com/AccelerateHS/acceleratehs.github.io/raw/master/papers/acc-cuda-damp2011.bib)

