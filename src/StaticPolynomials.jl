__precompile__()

module StaticPolynomials

    import MultivariatePolynomials as MP
    import StaticArrays: SVector, MVector, SMatrix
    import LinearAlgebra

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
