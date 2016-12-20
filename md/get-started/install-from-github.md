---
section: "Get Started"
nav-get-started: True
---

# Install from GitHub

## Checkout & Build

The recommend way to build and install the development version of _Accelerate_
is to use the [`stack`](http://www.haskellstack.org) build tool. This will
automatically pull in other in-development Accelerate packages from GitHub, as
well as dependencies from Hackage. `stack` can also be used to download and
install an appropriate version of GHC. Instructions and downloads for installing
`stack` are available for several operating systems and distributions on the
[haskellstack.org](https://docs.haskellstack.org/en/stable/README/#how-to-install)
website.

Note that you will still need to install necessary external libraries, such as
LLVM, as described on the [getting started](/get-started.html) page.

For example, to build the development version of the LLVM backends:

  1. Download the sources for `accelerate-llvm`:
```sh
git clone https://github.com/AccelerateHS/accelerate-llvm.git
```

  1. We maintain stack configurations for several GHC releases. Change directory
     to the newly downloaded sources and tell `stack` which version of GHC you
     would like to compile for by creating a symlink to the appropriate file
     named `stack.yaml`. For example, to use GHC-8.0:
```sh
cd accelerate-llvm
ln -s stack-8.0.yaml stack.yaml
```

  1. If you wish to make any changes to the build configuration, now is a good
     time to open the `stack.yaml` file in a text editor and make the necessary
     changes. For example:

    * If you do not have a CUDA capable GPU, you will not be able to build the
      `accelerate-llvm-ptx` package, in which case it is worthwhile commenting
      that out from the `packages:` stanza.

    * You can enable (or disable) building the Accelerate packages with extra
      debugging information by changing the `flags:` stanza at the bottom of the
      file.

  1. Allow stack to fetch any prerequisites, including an appropriate version of
     GHC if necessary:
```sh
stack setup
```

  1. Build the LLVM backends:
```sh
stack build
```

If you want to load the sources into `ghci`, use the command `stack exec ghci`.


## List of GitHub repositories

Core packages:

  * [accelerate](https://github.com/AccelerateHS/accelerate): Core language and compiler
  * [accelerate-llvm](https://github.com/AccelerateHS/accelerate-llvm): LLVM-based backends targeting multicore CPUs and CUDA GPUs
  * [accelerate-io](https://github.com/AccelerateHS/accelerate-io): Fast conversions between Accelerate arrays and other array formats (including [repa](https://hackage.haskell.org/package/repa) and [vector](https://hackage.haskell.org/package/vector))
  * [accelerate-fft](https://github.com/AccelerateHS/accelerate-fft): Fast Fourier transform implementation, with FFI bindings to optimised implementations
  * [accelerate-examples](https://github.com/AccelerateHS/accelerate-examples): Computational kernels and applications showcasing the use of Accelerate as well as a regression test suite

Libraries:

  * [colour-accelerate](https://github.com/tmcdonell/colour-accelerate): Colour representations in Accelerate (RGB, sRGB, HSV, and HSL)
  * [gloss-accelerate](https://github.com/tmcdonell/gloss-accelerate): Generate [gloss](https://hackage.haskell.org/package/gloss) pictures from Accelerate
  * [gloss-raster-accelerate](https://github.com/tmcdonell/gloss-accelerate): Parallel rendering of raster images and animations
  * [lens-accelerate](https://github.com/tmcdonell/lens-accelerate): [Lens](https://hackage.haskell.org/package/lens) operators for Accelerate types
  * [linear-accelerate](https://github.com/tmcdonell/linear-accelerate): [Linear](https://hackage.haskell.org/package/linear) vector spaces in Accelerate
  * [mwc-random-accelerate](https://github.com/tmcdonell/mwc-random-accelerate): Generate Accelerate arrays filled with high quality pseudorandom numbers
  * [numeric-prelude-accelerate](https://github.com/tmcdonell/numeric-prelude-accelerate): Lifting the [numeric-prelude](https://hackage.haskell.org/package/numeric-prelude) to Accelerate (incomplete)

Deprecated:

  * [accelerate-cuda](https://github.com/AccelerateHS/accelerate-cuda): CUDA-based backend for NVIDIA GPUs


## Further information

  * A meta-repository containing `stack` configurations pointing to the most
    recent development versions of all packages we maintain is available
    [here](https://github.com/tmcdonell-bot/accelerate-travis-buildbot). Its
    purpose is mostly to ensure that all packages build together successfully,
    which you can check via the [travis build log](https://travis-ci.org/tmcdonell-bot/accelerate-travis-buildbot/builds).

