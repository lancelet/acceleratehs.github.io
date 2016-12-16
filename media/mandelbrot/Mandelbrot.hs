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

-- centre: (-0.7 + 0i)
--  width: 3.067

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
-- Uses the method described here:
-- <http://stackoverflow.com/questions/16500656/which-color-gradient-is-used-to-color-mandelbrot-in-wikipedia>
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

