---
section: Examples
nav-examples: True
---

# Mandelbrot

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


## Tutorial

### Computing the set

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

<div class="alert alert-info" role="alert">
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

To determine whether an individual point $c$ is in the set, we use the scalar
iteration operation `while` to keep applying the `step` function, either until
the point diverges or some maximum iteration limit is reached.

Once we know how to compute an individual point, we can use the array operation
`generate` to perform the computation at every point in the complex plane in
parallel. Our final Mandelbrot function is:
```haskell
mandelbrot
    :: Int                  -- ^ image width
    -> Int                  -- ^ image height
    -> Int                  -- ^ iteration limit
    -> Complex Float        -- ^ view centre
    -> Float                -- ^ view width
    -> Acc (Array DIM2 (Complex Float, Int))
mandelbrot screenX screenY depth (x0 :+ y0) width =
  A.generate (A.constant (Z :. screenY :. screenX))
             (\ix -> let z0 = complexOfPixel ix
                         zn = while (\zi -> snd zi < constant depth && dot (fst zi) < 4.0)
                                    (\zi -> step z0 zi)
                                    (lift (z0, constant 0))
                     in
                     zn)
  where
    complexOfPixel :: Exp DIM2 -> Exp (Complex Float)
    complexOfPixel (unlift -> Z :. y :. x) = ...
```
The omitted function `complexOfPixel` is used to convert an array index into the
corresponding position in the complex plane. See the full code listing below for
its implementation.


### Generating an image

In order to generate a beautiful representation of the points in the Mandelbrot
set, we need to convert the number of iterations $n$ before the point diverged
into a colour. There are many ways colour schemes we could use; for the image
shown above, we map the iteration count into the following colour scheme:

<img class="img-responsive center-block" src="/media/mandelbrot/ultra.jpg">

The `colour-accelerate` library provides data types and operations for working
with several colour spaces in Accelerate. Standard RGB triples are defined in
the following module:
```haskell
import Data.Array.Accelerate.Data.Colour.RGB
```

Our colour scheme consists of five control points. Given a number $p$ between 0
and 1.0, the following function linearly interpolates between the two
surrounding control points to produce a smooth gradient.
```haskell
ultra :: Exp Float -> Exp Colour
ultra p =
  if p <= p1 then blend (p-p0) (p1-p) c1 c0 else
  if p <= p2 then blend (p-p1) (p2-p) c2 c1 else
  if p <= p3 then blend (p-p2) (p3-p) c3 c2 else
  if p <= p4 then blend (p-p3) (p4-p) c4 c3 else
                  blend (p-p4) (p5-p) c5 c4
  where
    p0 = 0.0     ; c0 = rgb8 0   7   100
    p1 = 0.16    ; c1 = rgb8 32  107 203
    p2 = 0.42    ; c2 = rgb8 237 255 255
    p3 = 0.6425  ; c3 = rgb8 255 170 0
    p4 = 0.8575  ; c4 = rgb8 0   2   0
    p5 = 1.0     ; c5 = c0
```
Note that we have used the `RebindableSyntax` extension here so that we can
reuse Haskell's usual if-then-else syntax.

We can use this function to assign a colour to each point in the complex plane,
and then use the `accelerate-io` package to write the resulting array of colours
to a BMP image file:
```
writeImageToBMP :: FilePath -> Array DIM2 RGBA32 -> IO ()
```

We have omitted a few functions required to glue these operations together, but
the complete code listing is shown below.

## Code

The complete code listing for generating the Mandelbrot set image shown at the
top of the page. To compile the program:
```sh
ghc -O2 -threaded mandelbrot.hs
```
and execute it in parallel on the CPU:
```sh
./mandelbrot +RTS -N -RTS
```

```haskell
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
    -> Complex Float        -- ^ view centre
    -> Float                -- ^ view width
    -> Acc (Array DIM2 (Complex Float, Int))
mandelbrot screenX screenY depth (x0 :+ y0) width =
  A.generate (A.constant (Z :. screenY :. screenX))
             (\ix -> let z0 = complexOfPixel ix
                         zn = while (\zi -> snd zi < constant depth && dot (fst zi) < 4.0)
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
    :: Exp Int
    -> Exp (Complex Float, Int)
    -> Exp Colour
escapeToColour depth (unlift -> (z, n)) =
  if depth == n
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
  if p <= p1 then blend (p-p0) (p1-p) c1 c0 else
  if p <= p2 then blend (p-p1) (p2-p) c2 c1 else
  if p <= p3 then blend (p-p2) (p3-p) c3 c2 else
  if p <= p4 then blend (p-p3) (p4-p) c4 c3 else
                  blend (p-p4) (p5-p) c5 c4
  where
    p0 = 0.0     ; c0 = rgb8 0   7   100
    p1 = 0.16    ; c1 = rgb8 32  107 203
    p2 = 0.42    ; c2 = rgb8 237 255 255
    p3 = 0.6425  ; c3 = rgb8 255 170 0
    p4 = 0.8575  ; c4 = rgb8 0   2   0
    p5 = 1.0     ; c5 = c0


main :: P.IO ()
main =
  let img = A.map packRGB
          $ A.map (escapeToColour 255)
          $ mandelbrot 800 600 255 ((-0.7) :+ 0) 3.067
  in
  writeImageToBMP "mandelbrot.bmp" (run img)
```

