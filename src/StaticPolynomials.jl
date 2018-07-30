__precompile__()

module StaticPolynomials

    import MultivariatePolynomials
    const MP = MultivariatePolynomials
    import StaticArrays: SVector, MVector, SMatrix

    using Compat
    using Compat.LinearAlgebra

    if VERSION <= v"0.6.9"
        import Base: gradient
    else
        import LinearAlgebra: gradient
    end


    include("helpers.jl")
    include("sexponents.jl")
    include("polynomial.jl")

    include("codegen_helpers.jl")
    include("evalpoly.jl")
    include("evaluate_codegen.jl")
    include("gradient_codegen.jl")
    include("evaluation.jl")

    include("system.jl")

    include("show.jl")
end # module
