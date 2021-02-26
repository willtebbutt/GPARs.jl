# GPARs

[![Build Status](https://github.com/willtebbutt/GPARs.jl/workflows/CI/badge.svg)](https://github.com/willtebbutt/GPARs.jl/actions)
[![Coverage](https://codecov.io/gh/willtebbutt/GPARs.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/willtebbutt/GPARs.jl)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)
[![ColPrac: Contributor's Guide on Collaborative Practices for Community Packages](https://img.shields.io/badge/ColPrac-Contributor's%20Guide-blueviolet)](https://github.com/SciML/ColPrac)

GPARs.jl is a rudimentary implementation of the Gaussian Process Autoregressive Regressor (GPAR), introduced in [our AISTATS paper](http://proceedings.mlr.press/v89/requeima19a.html). See CITATION.bib for an appropriate bibtex citation.

We also maintain a [Python version of this package](https://github.com/wesselb/gpar) -- this is much more fully featured, and we recommend that you use this implementation if you require the full collection of techniques introduced in that paper.

## Basic Usage

```julia
using GPARs
using Random
using Stheno

# Build a GPAR from a collection of GPs. For more info on how to specify particular
# kernels and their parameters, please see [Stheno.jl](https://github.com/willtebbutt/Stheno.jl). You should think of this as a vector-valued regressor.
f = GPAR([GP(EQ(), GPC()) for _ in 1:3])

# Specify inputs. `ColVecs` says "interpret this matrix as a vector of column-vecrors".
# Inputs are 2 dimensional, and there are 10 of them.
x = ColVecs(randn(2, 10))

# Specify noise variance for each output.
Σs = rand(3) .+ 0.1

# Generate samples from the regressor at inputs `x` under observation noise `Σs`.
# You'll see that these are `ColVecs` of length `N`, each element of which is a length 3
# vector.
y = rand(MersenneTwister(123456), f(x, Σs))
y.X # this produces the matrix underlying the observations.

# Compute the log marginal likelihood of the observations under the model.
logpdf(f(x, Σs), y)

# Generate a new GPAR that is conditioned on these observations. This is just another
# GPAR object (in the simplest case, GPARs are closed under conditioning).
f_post = GPARs.posterior(f(x, Σs), y)

# Since `f_post` is just another GPAR, we can use it to generate posterior samples
# and to compute log posterior predictive probabilities in the same way as the prior.
x_post = ColVecs(randn(2, 15))
y_post = rand(rng, f_post(x, Σs))
logpdf(f_post(x, Σs), y_post)
```
