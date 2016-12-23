---
section: Examples
nav-examples: True
---

# Mandelbrot set

The [Mandelbrot set](https://en.wikipedia.org/wiki/Mandelbrot_set) is generated
by sampling complex numbers $c$ in the complex plane, and determining whether
under iteration of the polynomial:

<p style="text-align: center;">
$z_{n+1} = c + z_n^2$
</p>

that the magnitude of $z$ (written $|z_n|$) remains bounded however large $n$
gets. Images of the Mandelbrot set are created such that each pixel corresponds
to a point $c$ in the complex plane, and its colour depends on the number of
iterations $n$ before the iteration diverges, where $z_0 = c$. The set of points
forming the boundary of this relation forms the distinctive and easily
recognisable fractal shape shown in the following image, which this page will
explain how to create in Accelerate.

<img class="img-responsive center-block" src="/media/mandelbrot/mandelbrot.jpg" alt="Mandelbrot set">


## Escape time algorithm

Complex numbers are available in Accelerate by importing the following module:
```haskell
import Data.Array.Accelerate.Data.Complex
```
The function `next` embodies the core equation governing the Mandelbrot set; it
computes the value $z_{n+1}$ at a given point $c$:
```haskell
next :: Exp (Complex Float) -> Exp (Complex Float) -> Exp (Complex Float)
next c z = c + z * z
```
Notice that the usual `Num` operations such as `(+)` and `(*)` have already been
defined for us for complex numbers in `Exp`. So, other than the type signature,
this is the same definition as for regular Haskell.

Thinking about the program as a whole, we need to iterate the function `next`,
and remember the number of iterations until it diverged. In practice, we iterate
the equation for a fixed maximum number of times, and if it has not diverged we
declare the point to be in the set. We can keep track of the value $z$ and the
current iteration number $i$ by combining them together:
```haskell
step :: Exp (Complex Float) -> Exp (Complex Float, Int) -> Exp (Complex Float, Int)
step c (unlift -> (z, i)) = lift (next c z, i + constant 1)
```
Here `step` takes the original value $c$, together with the current value $z_n$
and iteration number $i$ bundled in a pair of type `Exp (Complex Float, Int)`.
Unlike in regular Haskell, we can't use pattern matching to access the
components of the pair. Accelerate provides a few ways to get at the values, for
example the usual functions `fst` and `snd` for extracting the first and second
component respectively:
```haskell
fst :: (Elt b, Elt a) => Exp (a, b) -> Exp a
snd :: (Elt b, Elt a) => Exp (a, b) -> Exp b
```
More generally, and as we have used here (in a [view
pattern](https://downloads.haskell.org/~ghc/latest/docs/html/users_guide/glasgow_exts.html#view-patterns)),
the function `unlift` can be used unpack constructors into their components. In
this instance, we used `unlift` at the type:
```haskell
unlift :: (Elt a, Elt b) => Exp (a, b) -> (Exp a, Exp b)
```
Notice how `unlift` converts an `Exp` pair into a pair of components in `Exp`.
Conversely, when constructing the result we use its dual `lift` at the following
type in order to combine the two components back into an `Exp` pair:
```haskell
lift :: (Exp a, Exp b) => (Exp a, Exp b) -> Exp (a, b)
```

<div class="alert alert-warning" role="alert">
**Heads up!** The use of `lift` and `unlift` is probably the most common source
of type errors when using Accelerate. Since these are very general functions for
constructing and deconstructing product types, GHC often has trouble determining
what the type of an expression should be. If you run into trouble, try adding an
explicit type signature to fix the type.
</div>

In order to test whether the point has diverged yet, we need to compute the
magnitude of the complex number. We know that $|z|$ will definitely diverge if
it is greater than 2. The magnitude of a complex number $(x + i y)$ is given by
$\sqrt{x^2 + y^2}$, so we can simplify the conditional by squaring both sides
and changing the divergence test to $x^2 + y^2 \gt 4$:
```haskell
dot :: Exp (Complex Float) -> Exp Float
dot (unlift -> x :+ y) = x*x + y*y
```
Notice how we used `unlift` here to access the components of the complex number,
and in this instance it had the type:
```haskell
unlift :: Elt a => Exp (Complex a) -> Complex (Exp a)
```
Note that our divergence test $|z_n| \gt 4$ defines the _boundary_ of the
Mandelbrot set, but for points near the boundary it is also interesting to see
how quickly that point diverges, so we will leave this limit as a configurable
parameter `radius`. This also allows us to create more aesthetically pleasing
images, which we will return to later.

To determine whether an individual point $c$ is in the set, we use the scalar
iteration operation `while` to keep applying the `step` function, either until
the point diverges or some maximum iteration limit is reached.
```haskell
while :: Elt e
      => (Exp e -> Exp Bool)  -- ^ keep looping while 'True'
      -> (Exp e -> Exp e)     -- ^ body of the loop
      -> Exp e                -- ^ initial value
      -> Exp e
```

Once we know how to compute an individual point, we can use the array operation
`generate` to perform the computation at every point in the complex plane in
parallel. Our final Mandelbrot function is:
```haskell
mandelbrot
    :: Int                    -- ^ image width
    -> Int                    -- ^ image height
    -> Int                    -- ^ iteration limit
    -> Float                  -- ^ divergence radius
    -> Complex Float          -- ^ view centre
    -> Float                  -- ^ view width
    -> Acc (Array DIM2 (Complex Float, Int))
mandelbrot screenX screenY depth radius (x0 :+ y0) width =
  A.generate (A.constant (Z :. screenY :. screenX))
             (\ix -> let z0 = complexOfPixel ix
                         zn = while (\zi -> snd zi       < constant depth
                                         && dot (fst zi) < constant radius)
                                    (\zi -> step z0 zi)
                                    (lift (z0, constant 0))
                     in
                     zn)
  where
    complexOfPixel :: Exp DIM2 -> Exp (Complex Float)
    complexOfPixel (unlift -> Z :. y :. x) = ...
```
The omitted function `complexOfPixel` is used to convert each array index into
the corresponding position in the complex plane. See the full code listing below
for its implementation.


## Smooth colouring

In order to generate a beautiful representation of the points in the Mandelbrot
set, we need to convert the number of iterations $n$ before the point diverged
into a colour.

The `colour-accelerate` library provides data types and operations for working
with several colour spaces in Accelerate. Standard RGB triples are defined in
the following module:
```haskell
import Data.Array.Accelerate.Data.Colour.RGB
```

There are many ways colour schemes we could use; for the image shown above, we
use a colour scheme with five control points:
```haskell
p0 = 0.0     ; c0 = rgb8 0   7   100
p1 = 0.16    ; c1 = rgb8 32  107 203
p2 = 0.42    ; c2 = rgb8 237 255 255
p3 = 0.6425  ; c3 = rgb8 255 170 0
p4 = 0.8575  ; c4 = rgb8 0   2   0
```
where the positions $p$ are in the range $[0,1]$ and the corresponding colour is
given as RGB components from 0 to 255.

To calculate the colour at any point we can find the control points which lie to
either side of that point, and [linearly
interpolate](https://en.wikipedia.org/wiki/Linear_interpolation) between the two
corresponding colour values. However, this does not produce a smooth gradient,
so instead we will use [monotone cubic
interpolation](https://en.wikipedia.org/wiki/Monotone_cubic_interpolation). You
can see the difference between the two methods below:

<img class="img-responsive center-block" src="/media/mandelbrot/ultra-linear.jpg">

<img class="img-responsive center-block" src="/media/mandelbrot/ultra-cubic.jpg">

With some pre-processing to determine appropriate values $m$ necessary for the
cubic interpolation, the following function will generate a smooth function
given a number $p$ between $0$ and $1.0$.
```haskell
ultra :: Exp Float -> Exp Colour
ultra p =
  if p <= p1 then interp (p0,p1) (c0,c1) (m0,m1) p else
  if p <= p2 then interp (p1,p2) (c1,c2) (m1,m2) p else
  if p <= p3 then interp (p2,p3) (c2,c3) (m2,m3) p else
  if p <= p4 then interp (p3,p4) (c3,c4) (m3,m4) p else
                  interp (p4,p5) (c4,c5) (m4,m5) p
  where
    interp (x0,x1) (y0,y1) ((mr0,mg0,mb0),(mr1,mg1,mb1)) x =
      let
          RGB r0 g0 b0 = unlift y0 :: RGB (Exp Float)
          RGB r1 g1 b1 = unlift y1 :: RGB (Exp Float)
      in
      rgb (cubic (x0,x1) (r0,r1) (mr0,mr1) x)
          (cubic (x0,x1) (g0,g1) (mg0,mg1) x)
          (cubic (x0,x1) (b0,b1) (mb0,mb1) x)
```
where the omitted function `cubic` computes the [Cubic Hemite
spline](https://en.wikipedia.org/wiki/Cubic_Hermite_spline).

Note that in the function `ultra` we used the `RebindableSyntax` extension so
that we could reuse Haskell's standard if-then-else syntax. This is just
syntactic sugar which inserts the Accelerate scalar infix conditional operator:
```haskell
(?) :: Elt t => Exp Bool -> (Exp t, Exp t) -> Exp t
```
<div class="alert alert-danger" role="alert">
**Conditionals in parallel code:** As a rule of thumb, using conditionals in GPU
code is considered bad because branches cause _SIMD divergence_. This means that
when a GPU hits a conditional instruction, it first runs all the threads [of a
warp] that take the true branch, and then runs all the threads that take the
false branch. If you have nested conditionals, the amount of parallelism rapidly
decreases.
</div>

<div class="alert alert-info" role="alert">
**Exercise:** In the function `ultra` the conditionals are really only used to
supply appropriate input values to the subroutine `interp`, which does all the
real work. See if you can restructure the function so that the branching occurs
before the call to `interp`, so that all the threads perform the computation in
parallel with the appropriate input values.

_HINT:_

  * You can use `lift` to combine multiple values together into a tuple;
    `unlift` is used to deconstruct the tuple to access the individual values.

  * It is sometimes convenient to use the [lens-accelerate](#) library to access
    the values of (nested) tuples.

  * See the section [TK](#) to learn how to check the code that is generated and
    compare the two approaches.
</div>

Finally, we can assign a colour to each point on the complex plane given the
iteration count at which that point diverged. In order to avoid obvious "bands"
of colour, we use the following continuous colouring scheme:
```haskell
escapeToColour
    :: Int
    -> Exp (Complex Float, Int)
    -> Exp Colour
escapeToColour limit (unlift -> (z, n)) =
  if n == constant limit
    then black
    else ultra (toFloating ix / toFloating points)
      where
        mag     = magnitude z
        smooth  = logBase 2 (logBase 2 mag)
        ix      = truncate (sqrt (toFloating n + 1 - smooth) * scale + shift) `mod` points
        --
        scale   = 256
        shift   = 1664
        points  = 2048 :: Exp Int
```
where any point which reached the iteration limit is immediately set to `black`.
The `colour-accelerate` package includes several predefined colours in the
module:
```haskell
import Data.Array.Accelerate.Data.Colour.Names
```

## Saving images to disk

After we compute the image, we can use the following function from the
`accelerate-io` package to save the data to a BMP image file:
```haskell
writeImageToBMP :: FilePath -> Array DIM2 RGBA32 -> IO ()
```
together with the function `packRGB` from `colour-accelerate` to generate the
necessary packed `RGBA32` representation, where each colour component is encoded
as an 8-bit value and packed together into a single 32-bit word:
```haskell
packRGB :: Exp Colour -> Exp RGBA32
```

To generate the complete Mandelbrot image we apply each of the above steps in
sequence, which Accelerate will optimise and fuse into a single loop:
```haskell
img = map packRGB
    $ map (escapeToColour limit)
    $ mandelbrot width height limit radius ((-0.7) :+ 0) 3.067
```
The complete code listing is shown below.

## Next steps

The `accelerate-examples` package includes an implementation of the Mandelbrot
program shown here, with interactive controls allowing you to explore the set in
real time.


## Code

The complete code for generating the Mandelbrot set image shown at the top of
the page is below. To compile the program:
```sh
ghc -O2 -threaded Mandelbrot.hs
```
and execute it in parallel on the CPU:
```sh
./mandelbrot +RTS -N -RTS
```

```haskell
{-# LANGUAGE FlexibleContexts    #-}
{-# LANGUAGE RebindableSyntax    #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeOperators       #-}
{-# LANGUAGE ViewPatterns        #-}

import Data.Array.Accelerate                              as A
import Data.Array.Accelerate.IO                           as A
import Data.Array.Accelerate.Data.Complex                 as A
import Data.Array.Accelerate.Data.Colour.RGB              as A
import Data.Array.Accelerate.Data.Colour.Names            as A

import Data.Array.Accelerate.LLVM.Native                  as CPU
-- import Data.Array.Accelerate.LLVM.PTX                     as PTX

import qualified Prelude                                  as P

mandelbrot
    :: Int                  -- ^ image width
    -> Int                  -- ^ image height
    -> Int                  -- ^ iteration limit
    -> Float                -- ^ divergence radius
    -> Complex Float        -- ^ view centre
    -> Float                -- ^ view width
    -> Acc (Array DIM2 (Complex Float, Int))
mandelbrot screenX screenY limit radius (x0 :+ y0) width =
  A.generate (A.constant (Z :. screenY :. screenX))
             (\ix -> let z0 = complexOfPixel ix
                         zn = while (\zi -> snd zi       < constant limit
                                         && dot (fst zi) < constant radius)
                                    (\zi -> step z0 zi)
                                    (lift (z0, constant 0))
                     in
                     zn)
  where
    -- Convert the given array index, representing a pixel in the final image,
    -- into the corresponding point on the complex plane.
    --
    complexOfPixel :: Exp DIM2 -> Exp (Complex Float)
    complexOfPixel (unlift -> Z :. y :. x) =
      let
          height = P.fromIntegral screenY / P.fromIntegral screenX * width
          xmin   = x0 - width  / 2
          ymin   = y0 - height / 2
          --
          re     = constant xmin + (fromIntegral x * constant width)  / constant (P.fromIntegral screenX)
          im     = constant ymin + (fromIntegral y * constant height) / constant (P.fromIntegral screenY)
      in
      lift (re :+ im)

    -- Divergence condition
    --
    dot :: Exp (Complex Float) -> Exp Float
    dot (unlift -> x :+ y) = x*x + y*y

    -- Take a single step of the recurrence relation
    --
    step :: Exp (Complex Float) -> Exp (Complex Float, Int) -> Exp (Complex Float, Int)
    step c (unlift -> (z, i)) = lift (next c z, i + constant 1)

    next :: Exp (Complex Float) -> Exp (Complex Float) -> Exp (Complex Float)
    next c z = c + z * z


-- Convert the iteration count on escape to a colour.
--
escapeToColour
    :: Int
    -> Exp (Complex Float, Int)
    -> Exp Colour
escapeToColour limit (unlift -> (z, n)) =
  if n == constant limit
    then black
    else ultra (toFloating ix / toFloating points)
      where
        mag     = magnitude z
        smooth  = logBase 2 (logBase 2 mag)
        ix      = truncate (sqrt (toFloating n + 1 - smooth) * scale + shift) `mod` points
        --
        scale   = 256
        shift   = 1664
        points  = 2048 :: Exp Int

-- Pick a nice colour, given a number in the range [0,1].
--
ultra :: Exp Float -> Exp Colour
ultra p =
  if p <= p1 then interp (p0,p1) (c0,c1) (m0,m1) p else
  if p <= p2 then interp (p1,p2) (c1,c2) (m1,m2) p else
  if p <= p3 then interp (p2,p3) (c2,c3) (m2,m3) p else
  if p <= p4 then interp (p3,p4) (c3,c4) (m3,m4) p else
                  interp (p4,p5) (c4,c5) (m4,m5) p
  where
    p0 = 0.0     ; c0 = rgb8 0   7   100  ; m0 = (0.7843138, 2.4509804,  2.52451)
    p1 = 0.16    ; c1 = rgb8 32  107 203  ; m1 = (1.93816,   2.341629,   1.6544118)
    p2 = 0.42    ; c2 = rgb8 237 255 255  ; m2 = (1.7046283, 0.0,        0.0)
    p3 = 0.6425  ; c3 = rgb8 255 170 0    ; m3 = (0.0,       -2.2812111, 0.0)
    p4 = 0.8575  ; c4 = rgb8 0   2   0    ; m4 = (0.0,       0.0,        0.0)
    p5 = 1.0     ; c5 = c0                ; m5 = m0

    -- interpolate each of the RGB components
    interp (x0,x1) (y0,y1) ((mr0,mg0,mb0),(mr1,mg1,mb1)) x =
      let
          RGB r0 g0 b0 = unlift y0 :: RGB (Exp Float)
          RGB r1 g1 b1 = unlift y1 :: RGB (Exp Float)
      in
      rgb (cubic (x0,x1) (r0,r1) (mr0,mr1) x)
          (cubic (x0,x1) (g0,g1) (mg0,mg1) x)
          (cubic (x0,x1) (b0,b1) (mb0,mb1) x)

-- cubic interpolation
cubic :: (Exp Float, Exp Float)
      -> (Exp Float, Exp Float)
      -> (Exp Float, Exp Float)
      -> Exp Float
      -> Exp Float
cubic (x0,x1) (y0,y1) (m0,m1) x =
  let
      -- basis functions for cubic hermite spine
      h_00 = (1 + 2*t) * (1 - t) ** 2
      h_10 = t * (1 - t) ** 2
      h_01 = t ** 2 * (3 - 2 * t)
      h_11 = t ** 2 * (t - 1)
      --
      h    = x1 - x0
      t    = (x - x0) / h
  in
  y0 * h_00 + h * m0 * h_10 + y1 * h_01 + h * m1 * h_11

-- linear interpolation
linear :: (Exp Float, Exp Float)
       -> (Exp Float, Exp Float)
       -> Exp Float
       -> Exp Float
linear (x0,x1) (y0,y1) x =
  y0 + (x - x0) * (y1 - y0) / (x1 - x0)


main :: P.IO ()
main =
  let
      width   = 800
      height  = 600
      limit   = 1000
      radius  = 256
      --
      img = A.map packRGB
          $ A.map (escapeToColour limit)
          $ mandelbrot width height limit radius ((-0.7) :+ 0) 3.067
  in
  writeImageToBMP "mandelbrot.bmp" (run img)
```

