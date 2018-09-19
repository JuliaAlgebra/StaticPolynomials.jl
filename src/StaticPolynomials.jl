__precompile__()

module StaticPolynomials

    import MultivariatePolynomials
    const MP = MultivariatePolynomials
    import StaticArrays: SVector, MVector, SMatrix
    import LinearAlgebra
    if VERSION < v"1.0-"
        import LinearAlgebra: gradient
    end

    include("helpers.jl")
    include("sexponents.jl")
    include("polynomial.jl")
    include("show.jl")

    include("codegen_helpers.jl")
    include("evalpoly.jl")
    include("evaluate_codegen.jl")
    include("gradient_codegen.jl")
    include("evaluation.jl")

    include("polynomial_system.jl")
end # module
