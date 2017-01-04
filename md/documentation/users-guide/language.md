---
section: Documentation
nav-documentation: True
toc: False
---

<ol class="breadcrumb">
  <li><a href="/documentation/users-guide.html">Users Guide</a></li>
  <li class="active">The <i>Accelerate</i> Language</li>
</ol>


# The _Accelerate_ Language

_Accelerate_ is an embedded language of array-based computations for
high-performance computing in Haskell. Programs in Accelerate are expressed in
the form of parameterised collective operations on regular multidimensional
arrays, such as maps, reductions, and permutations. Accelerate then takes these
computations and optimises, compiles, and executes them for the chosen target
architecture.

Accelerate is an _embedded language_, which distinguishes between vanilla
Haskell arrays and embedded language arrays, as well as the computations on each
of these. Programs written in Accelerate are not compiled by the regular Haskell
compiler (GHC). Rather, each Accelerate backend is a _runtime compiler_ which
generates and executes [parallel SIMD] code of the target architecture at
application _runtime_.

Accelerate distinguishes the types of collective operations `Acc` from the type
of scalar operations `Exp` to achieve a _stratified language_. Collective
operations comprise many scalar computations which are executed in parallel, but
scalar computations _can not_ initiate new collective operations. This
distinction excludes _nested, irregular_ data-parallelism statically; instead,
Accelerate is limited to _flat data-parallelism_ involving only regular,
multi-dimensional arrays.


## Embedded array computations

The type constructor `Acc` represents embedded collective array operations. A
term of type `Acc a` is an Accelerate program which, once executed, will produce
a value of type `a` (consisting of one or more arrays). Collective operations of
type `Acc a` comprise many _scalar expressions_, represented by the type `Exp`,
which will be executed in parallel. Although collective operations comprise many
scalar operations executed in parallel, scalar operations _can not_ initiate new
collective operations. This stratification between scalar operations in `Exp`
and collective operations in `Acc` helps to statically exclude _nested
data-parallelism_, which is difficult to execute efficiently on constrained
hardware such as GPUs.

For example, to compute a vector dot product we can write:

```haskell
import Data.Array.Accelerate  as A
import qualified Prelude      as P

dotp :: Num a => Vector a -> Vector a -> Acc (Scalar a)
dotp xs ys =
  let
      xs' = use xs
      ys' = use ys
  in
  fold (+) 0 ( zipWith (*) xs' ys' )
```

The function `dotp` consumes two one-dimensional arrays (`Vector`s) of values,
and produces a single (`Scalar`) result as output. As the return type is wrapped
in `Acc`, we see that it is an embedded Accelerate computation---it will be
evaluated in the _object_ language of dynamically generated parallel code,
rather than the _meta_ language of vanilla Haskell.

The arguments to `dotp` are plain Haskell arrays (not wrapped in `Acc`). To make
these arrays accessible to Accelerate computations, they must first be embedded
with the `use` function. This turns a regular, vanilla array, or tuple of
arrays, into an Accelerate array:

```haskell
use :: Arrays a => a -> Acc a
```

An Accelerate backed is use to evaluate the embedded computation and return the
result back to vanilla Haskell. Calling the `run` function of a backend will
generate code for the target architecture, compile, and execute it. Currently
the following backends are available:

  - [accelerate-llvm-native](#TK): for execution on shared-memory multicore CPUs
  - [accelerate-llvm-ptx](#TK): for execution on NVIDIA CUDA-capable GPUs

See the [Getting Started](/get-started.html) section for instructions on
installing these backends.

<div class="alert alert-success" role="alert">
**Tip!** Since `Acc` represents embedded computations that will only be executed
when evaluated by a backend, we can programmatically generate computations using
the meta language (Haskell): for example, unrolling loops or embedding input
values directly into the generated code. See the [fluid
simulation](/examples/fluid.html) program for an example.
</div>

<div class="alert alert-warning" role="alert">
**Heads up!** It is usually best to keep all intermediate computations in `Acc`, and
only `run` the computation at the very end to produce the final result. This
enables optimisations between intermediate computations (e.g. array fusion) and,
if the target architecture has a separate memory space, as is the case of GPUs,
to prevent excessive data transfers.
</div>

## Embedded scalar operations

The type constructor `Exp` represents embedded scalar expressions. The
collective operations in Accelerate of type `Acc` consist of many scalar
operations of type `Exp` executed in parallel.

Accelerate implements (or redefines) instances for the familiar Haskell type
classes for scalar expressions. In the `dotp` program above, this allows us to
make use of the usual numeric operations `(+)` and `(*)` from the `Num`
typeclass, applied to embedded scalar expressions.

Analogously to `use`, to make scalar values accessible to Accelerate
computations they must first be embedded with the `constant` function.

```haskell
use :: Elt t => t -> Exp t
```

<div class="alert alert-success" role="alert">
**Tip!** For constant numeric values this is often performed automatically.
Notice in the `dotp` program we did not need to use the `constant` function to
inject the initial value 0. This is because GHC applies the `fromInteger`
function of the `Num` typeclass (or the `fromRational` function of the
`Fractional` typeclass for floating point values) to the constant value, which
implements the lifting operation for us.
</div>


## Arrays

The `Array` is the core computational unit of Accelerate. Computations in
Accelerate take the form of collective operations over arrays of the type `Array
sh e`. All programs in Accelerate take zero or more arrays as input and produce
one or more arrays as output. The `Array` type has two parameters:

  - _sh_: is the shape of the array, tracking the dimensionality and extent of
    each dimension of the array. For example, `DIM1` is the type of the shape of
    a one dimensional array (`Vector`), `DIM2` for two-dimensional arrays, and
    so on. See the section [array shapes](#array-shapes-indices) for more
    information.

  - _e_: represents the type each array element, such as `Int` or `Float`. See
    the section on allowable [array element types](#array-elements) for more
    information.

Array data is stored unboxed in an unzipped struct-of-array representation, and
elements are laid out in row-major order (the right-most index of the shape is
the fastest varying).

If the object code is executed in a separate memory space, for example on a GPU,
arrays will be transferred to the target device as necessary (asynchronously and
in parallel with other tasks) and cached on the device as long as sufficient
memory is available.


### Array elements

The `Elt` class characterises the allowable array element types, and hence the
types which can appear in scalar Accelerate expressions. It roughly consists of:

  - Signed and unsigned integers (8, 16, 32, and 64-bits wide)
  - Floating point numbers (single and double precision)
  - `Char`
  - `Bool`
  - `()`
  - Shapes formed from `Z` and `(:.)`
  - [Foreign.C.Types](https://hackage.haskell.org/package/base/docs/Foreign-C-Types.html) for integral, floating-point, and characters
  - Nested tuples of all the above (currently up to 15-elements wide)

Note that `Array` itself is not an allowable array element type; there are no
nested arrays in Accelerate, only regular multi-dimensional arrays.

Accelerate arrays consist of these simple atomic types stored efficiently in
memory, as consecutive unpacked elements without pointers in an unzipped
struct-of-array format.

Adding new instances to `Elt` consists of explaining to Accelerate how to map
between your data type and a (tuple of) primitive values. For examples see:

  - [Data.Array.Accelerate.Data.Complex](#TK)
  - [Data.Array.Accelerate.Data.Monoid](#TK)
  - [linear-accelerate](/libraries/linear-accelerate.html)
  - [colour-accelerate](/libraries/colour-accelerate.html)


### Array shapes & indices

Operations in Accelerate consist of collective operations over arrays of type
`Array sh e`. Much like the [repa](https://hackage.haskell.org/package/repa)
library, the shape of an array, as well as array indices used to access
individual elements, are built inductively using `Z` and `(:.)` (analogously to
a list).

```haskell
data Z = Z
data tail :. head = tail :. head
```

The constructor `Z` corresponds to a shape with zero dimensions (or a `Scalar`
array consisting of a single element) and us used to mark the end of the list.
The constructor `(:.)` adds additional dimensions to the _right_ of an index.
For example:
```haskell
Z :. Int
```
is the type of the shape of a one-dimensional array (`Vector`) indexed by an
`Int`, while:
```haskell
Z :. Int :. Int
```
is the type of the shape of a two-dimensional array indexed by an `Int` in each
dimension.

This style is used to construct both the _type_ (as shown above) as well as the
_value_ of a shape. For example, a vector of ten elements has the following
shape:
```haskell
sh :: Z :. Int
sh = Z :. 10
```

<div class="alert alert-warning" role="alert">
**Heads up!** The right-most index corresponds to the _innermost_ dimension.
This is the fastest-varying index, and corresponds to the elements of the array
which are adjacent in memory.
</div>

The common shape and array types that we have seen above are simply type
synonyms:
```haskell
type DIM0 = Z
type DIM1 = DIM0 :. Int
type DIM2 = DIM1 :. Int
  -- and so on...

type Scalar e = Array DIM0 e
type Vector e = Array DIM1 e
```

