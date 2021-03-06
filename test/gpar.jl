@testset "gpar" begin
    N = 10
    D_in = 2
    D_out = 3

    rng = MersenneTwister(123456)
    f = GPAR([GP(SEKernel()) for _ in 1:D_out])
    x = ColVecs(randn(D_in, N))
    Σs = [rand(rng) + 0.1 for _ in 1:D_out]

    # Check that the output of rand is of the correct dimensionality.
    y = rand(rng, f(x, Σs))
    @test length(y) == N
    @test size(y.X) == (D_out, N)

    # Check that logpdf returns something, and said this is real number.
    @test logpdf(f(x, Σs), y) isa Real

    # Check that the posterior is another GPAR.
    f_post = posterior(f(x, Σs), y)
    @test f_post isa GPAR

    # Check that quantities can be computed under the posterior.
    N_pred = 5
    x_pred = ColVecs(randn(rng, D_in, N_pred))
    y_post = rand(rng, f_post(x_pred, Σs))
    @test size(rand(rng, f_post(x_pred, Σs))) == size(y_post)
    @test logpdf(f_post(x_pred, Σs), y_post) isa Real
end
