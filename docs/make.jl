using Documenter, StaticPolynomials

makedocs(
    sitename = "StaticPolynomials.jl",
    pages = [
        "Introduction" => "index.md",
        "Reference" => "reference.md",
        ]
)

deploydocs(
    repo   = "github.com/JuliaAlgebra/StaticPolynomials.jl.git",
)
