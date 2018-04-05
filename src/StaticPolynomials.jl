__precompile__()

module StaticPolynomials

    import MultivariatePolynomials
    const MP = MultivariatePolynomials
    import StaticArrays: SVector, SMatrix

    using Compat
    using Compat.LinearAlgebra

    if VERSION <= v"0.6.2"
        import Base: gradient
    else
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

    include("system.jl")
end # module
