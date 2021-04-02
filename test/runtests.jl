using AbstractGPs
using GPARs
using Random
using Test

using GPARs: posterior

@testset "GPARs.jl" begin
    include("gpar.jl")
end
