---
section: Examples
nav-examples: True
---

# Canny edge detector

Implementation of the [canny edge
detector](https://en.wikipedia.org/wiki/Canny_edge_detector). The majority of
the algorithm is data-parallel and implemented in Accelerate, with the final
(sequential) phase implemented using
[repa](https://hackage.haskell.org/package/repa). Uses the
[accelerate-io](https://hackage.haskell.org/package/accelerate-io) package to
efficiently convert between the Accelerate and Repa array representations.

<div class="col-md-6">
  <img class="img-responsive center-block" src="/media/lena.bmp" alt="Original image">
  <p class="text-center text-muted">Original image</p>
</div>
<div class="col-md-6">
  <img class="img-responsive center-block" src="/media/canny.bmp" alt="Result">
  <p class="text-center text-muted">Result</p>
</div>

