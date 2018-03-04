__precompile__()

module StaticPolynomials

    import MultivariatePolynomials
    const MP = MultivariatePolynomials

    include("helpers.jl")
    include("sexponents.jl")
    include("polynomial.jl")
    include("show.jl")
    include("evaluate_codegen.jl")
    include("evaluation.jl")

end # module
