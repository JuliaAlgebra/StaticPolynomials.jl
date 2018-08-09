using Documenter, StaticPolynomials

makedocs(
    format = :html,
    sitename = "StaticPolynomials.jl",
    pages = [
        "Introduction" => "index.md",
        "Reference" => "reference.md",
        ]
)

deploydocs(
    repo   = "github.com/JuliaAlgebra/StaticPolynomials.jl.git",
    target = "build",
    julia = "0.7",
    osname = "linux",
    deps   = nothing,
    make   = nothing
)
