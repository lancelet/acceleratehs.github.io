---
section: Examples
nav-examples: True
---

# LULESH

This example implements the Livermore Unstructured Lagrangian Explicit Shock
Hydrodynamics ([LULESH](https://codesign.llnl.gov/lulesh.php)) application. This
shock hydrodynamics problem was originally defined and implemented by Lawrence
Livermore National Laboratory as one of the five challenge problem in the [DARPA
UHPC program](http://www.darpa.mil/Our_Work/MTO/Programs/Ubiquitous_High_Performance_Computing_%28UHPC%29.aspx) and has become a widely studied proxy application.

LULESH represents a typical hydrodynamics code such as [ALE3D](https://wci.llnl.gov/simulation/computer-codes/ale3d), but is a highly
simplified application, hard-coded to solve the Sedov blast problem on an
unstructured hexahedron mesh.

<img class="img-responsive center-block" src="/media/lulesh/ale3d.gif" alt="What LULESH models">

