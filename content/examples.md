---
section: Examples
nav-examples: True
---

Examples
========

## accelerate-examples

The [accelerate-examples](https://hackage.haskell.org/package/accelerate-examples)
package demonstrates a range of computational kernels and a few complete (albeit
small) applications, as well as a regression test suite. To install it:
```sh
cabal install accelerate-examples -fllvm-cpu
```
(Optional) If you have a CUDA capable NVIDIA GPU, additionally add the option
`-fllvm-ptx` to the above command line in order to enable the
`accelerate-llvm-ptx` backend.

All programs included with the package include a few common command line
arguments:

  * _--help_: Display information and options available for the current program.

  * _--llvm-cpu_: Execute using the LLVM backend for multicore CPUs. Specify the
    number of threads to use on the command line with `+RTS -Nx -RTS` to use _x_
    CPU cores (or omit _x_ to use as many cores as your machine has. For
    example:
```sh
accelerate-ray --llvm-cpu +RTS -N -RTS
```

  * _--llvm-ptx_: Execute using the LLVM backend for CUDA capable NVIDIA GPUs.
    Only available if `accelerate-examples` is compiled with the switch
    `-fllvm-ptx`.


Some of the included programs are:

### accelerate-nofib

<div class="container">
Regression test suite for Accelerate. In future we would also like to expand
this to include benchmarks in order to track performance regressions as well. If
you are experiencing problems with Accelerate, try running the test suite (it
will take some time) to hopefully narrow down the problem then open a ticket on
the [issue tracker](https://github.com/AccelerateHS/accelerate/issues).
</div>


### accelerate-canny

<div class="col-md-6">
Implementation of the [canny edge
detector](https://en.wikipedia.org/wiki/Canny_edge_detector) in Accelerate. The
majority of the algorithm is data-parallel and implemented in Accelerate, with
the final (sequential) phase implemented using
[repa](https://hackage.haskell.org/package/repa). Uses the
[accelerate-io](https://hackage.haskell.org/package/accelerate-io) package to
efficiently convert between the Accelerate and Repa array representations.

</div>
<div class="col-md-3">
  <img class="img-responsive center-block" src="/media/lena.bmp" alt="lena">
  <p class="text-center text-muted">Original image</p>
</div>
<div class="col-md-3">
  <img class="img-responsive center-block" src="/media/canny.bmp" alt="canny edge detector">
  <p class="text-center text-muted">Result</p>
</div>


### accelerate-fluid

<div class="col-md-8">
Implementation of the particle-based fluid simulation described in the paper
_Real-time Fluid Dynamics for Games_ by Jos Stam, GDC 2003
([pdf](http://www.dgp.toronto.edu/people/stam/reality/Research/pdf/GDC03.pdf)).

**Controls:**

To interact with the simulation window:

  * _click_: add particles to the simulation

  * _shift-click+drag_: introduce forces, proportional to the speed of motion

  * _r_: reset the simulation to the initial state

  * _d_: toggle display of the density (particle) field

  * _v_: toggle display of velocity field lines

</div>
<div class="col-md-4">
<div class="embed-responsive embed-responsive-1by1">
  <video controls class="embed-responsive-item" poster="/media/fluid.jpg">
    <source src="/media/fluid.mp4" type="video/mp4">
  </video>
</div>
</div>


### accelerate-hashcat

<div class="container">
This program attempts to recover the plain text of an MD5 hash by comparing the
unknown to the hash of every entry in a given dictionary.
</div>


### accelerate-kmeans

<div class="col-md-7">
In the [_K_-means problem](https://en.wikipedia.org/wiki/K-means_clustering),
the goal is to partition a set of observations into _k_ clusters, in which each
observation belongs to the cluster with the nearest mean. Finding an optimum
solution to the problem is NP-hard, however there exist efficient heuristic
algorithms that converge quickly to a local optimum. This example implements
[Lloyd's algorithm](https://en.wikipedia.org/wiki/Lloyd's_algorithm) specialised
to clustering points on a two-dimensional plane.
</div>
<div class="col-md-5">
  <img class="img-responsive center-block" src="/media/k-means.png" alt="k-means">
</div>


### accelerate-mandelbrot

<div class="col-md-7">
Implementation of the [Mandelbrot set](https://en.wikipedia.org/wiki/Mandelbrot_set).
The program is interactive so that you can explore the set.

**Controls:**

  * _arrows:_ pan the display in the corresponding direction

  * _z_, _;_: zoom in

  * _x_, _q_: zoom out

</div>
<div class="col-md-5">
  <img class="img-responsive center-block" src="/media/mandelbrot.jpg" alt="Mandelbrot set">
</div>


### accelerate-nbody

<div class="container">
The [_N_-body](https://en.wikipedia.org/wiki/N-body_simulation)
example simulates the Newtonian gravitational forces on a set of massive bodies
in 3D space, using a naive direct ( _O_(n<sup>2</sup>) ) algorithm. _N_-body
simulations are widely used in physics and astronomy.
</div>


### accelerate-pagerank

<div class=container>
A simplified version of the [PageRank](https://en.wikipedia.org/wiki/PageRank),
a link analysis algorithm which assigns a numerical weighting to each element of
a hyperlinked set of documents, with the purpose of determining the relative
importance of each document within that set. PageRank was developed at Google as
a method for measuring the importance of website pages.
</div>


### accelerate-ray

<div class="col-md-7">
Implementation of a simple [ray tracer](https://en.wikipedia.org/wiki/Ray_tracing_(graphics))
in Accelerate. The program supports multiple reflections, but is otherwise quite
basic. This simplicity however means the GUI program can be interactive.

**Controls:**

  * Use the W, A, S, and D keys to move the view port up, left, down, and right
    respectively.

  * Use the arrow keys to move the position of the light source in the
    corresponding direction.

</div>
<div class="col-md-5">
<div class="embed-responsive embed-responsive-4by3">
  <video controls loop class="embed-responsive-item" poster="/media/ray.jpg">
    <source src="/media/ray.mp4" type="video/mp4">
  </video>
</div>
</div>

