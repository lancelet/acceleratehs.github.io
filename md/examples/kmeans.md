---
section: Examples
nav-examples: True
---

# K-Means clustering

In the [_K_-means problem](https://en.wikipedia.org/wiki/K-means_clustering),
the goal is to partition a set of observations into _k_ clusters, in which each
observation belongs to the cluster with the nearest mean. Finding an optimum
solution to the problem is NP-hard, however there exist efficient heuristic
algorithms that converge quickly to a local optimum. This example implements
[Lloyd's algorithm](https://en.wikipedia.org/wiki/Lloyd's_algorithm) specialised
to clustering points on a two-dimensional plane.

<img class="img-responsive center-block" src="/media/k-means.png" alt="k-means">

