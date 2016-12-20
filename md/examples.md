---
section: Examples
nav-examples: True
---

# Examples

The [accelerate-examples](https://hackage.haskell.org/package/accelerate-examples)
package demonstrates a range of computational kernels and a few complete (albeit
small) applications, as well as a regression test suite. To install it:
```sh
cabal install accelerate-examples -fllvm-cpu
```
(Optional) If you have a CUDA capable NVIDIA GPU, add the flag `-fllvm-ptx` to
the above command line in order to enable the `accelerate-llvm-ptx` backend.

This package includes the regression test suite for Accelerate:
`accelerate-nofib`. In future we would also like to expand this to include
benchmarks in order to track performance regressions as well. If you are
experiencing problems with Accelerate, try running the test suite (it will take
some time) to hopefully narrow down the problem then open a ticket on the [issue
tracker](https://github.com/AccelerateHS/accelerate/issues).

Following are a few short example programs demonstrating language features and
[extra libraries](/libraries.html).


## Tutorials

Short example programs demonstrating particular language operations or
libraries.

  * [Mandelbrot set](/examples/mandelbrot.html): Generation of the classic
    Mandelbrot set fractal. Topics include:

      * Complex numbers
      * Creating arrays with the `generate` operator
      * Scalar iteration with `while`
      * Working with colours with the [colour-accelerate]() library
      * Writing BMP images to disk with the [accelerate-io]() library

  * [Canny edge detector](/examples/canny.html): Implementation of the Canny
    edge detection technique to extract edges from images. Topics include:

      * Image processing kernels using the `stencil` operator
      * Converting between Accelerate and Repa array representations using the
        [accelerate-io]() library

  * [Fluid simulation](/examples/fluid.html): A simple, interactive,
    particle-based fluid simulation. Topics include:

      * The `stencil` operator
      * Using Haskell as a meta-programming language to help generate the Accelerate program

  * [N-body simulation](/examples/nbody.html): _N_-body simulation of a group of
    bodies undergoing gravitational interaction. Demonstrates:

      * Use of [linear-accelerate]() library for small vector quantities
      * Use of [lens-accelerate]() library

  * [Ray-tracer](/examples/ray.html): A simple real-time ray-tracer.
    Demonstrates:

      * Use of [linear-accelerate]() library
      * Defining new data types for use within Accelerate programs

## Larger programs

  * [LULESH](/examples/lulesh.html): Implementation of the Livermore
    Unstructured Lagrangian Explicit Shock Hydrodynamics proxy application.


