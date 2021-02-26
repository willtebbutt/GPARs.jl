"""
    GPAR(fs)


"""
struct GPAR{Tfs} <: Stheno.AbstractGP # this is a bit of a hack, as a GPAR isn't a GP.
    fs::Tfs
end

dim_out(f::GPAR) = length(f.fs)

(f::GPAR)(x::ColVecs, Σs) = Stheno.FiniteGP(f, x, Σs)

const FiniteGPAR = Stheno.FiniteGP{<:GPAR}

extract_data(fx::FiniteGPAR) = fx.f, fx.x.X, fx.Σy

function Stheno.rand(rng::AbstractRNG, fx::FiniteGPAR)
    f, X, Σs = extract_data(fx)
    Y = Matrix{Float64}(undef, 0, length(fx.x))

    for p in 1:dim_out(f)
        x_p = ColVecs(vcat(X, Y))
        y_p = rand(rng, f.fs[p](x_p, Σs[p]))
        Y = vcat(Y, y_p')
    end
    return ColVecs(Y)
end

function Stheno.logpdf(fx::FiniteGPAR, y::ColVecs)
    f, X, Σs = extract_data(fx)
    Y = y.X

    l = logpdf(f.fs[1](ColVecs(X), Σs[1]), Y[1, :])
    for p in 2:dim_out(f)
        x_p = ColVecs(vcat(X, Y[1:p-1, :]))
        l += logpdf(f.fs[p](x_p, Σs[p]), Y[p, :])
    end
    return l
end

function posterior(fx::FiniteGPAR, y::ColVecs)
    f, X, Σs = extract_data(fx)
    Y = y.X
    fs_post = map(enumerate(f.fs)) do (p, f_p)
        x_p = ColVecs(vcat(X, Y[1:p-1, :]))
        return f_p | (f_p(x_p, Σs[p]) ← Y[p, :])
    end
    return GPAR(fs_post)
end
