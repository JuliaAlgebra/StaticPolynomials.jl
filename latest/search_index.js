var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Introduction",
    "title": "Introduction",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#Introduction-1",
    "page": "Introduction",
    "title": "Introduction",
    "category": "section",
    "text": "StaticPolynomials.jl is a library for fast evaluation of multivariate polynomials.Let f be a multivariate polynomial with support Asubset mathbbN^n. This package then uses Julia metaprogramming capabilities (@generated in particular) to generate specialized functions for the evaluation of f and its gradient. In order to achieve this the support is encoded in the type of f and a new function will be compiled for each newly encountered support. Therefore this is not suitable if you only evaluate f a couple of times.Since the polynomials in this package are optimised for fast evaluation they are not suited for construction of polynomials. It is recommended to construct a polynomial with an implementation of MultivariatePolynomials.jl, e.g. DynamicPolynomials.jl, and to convert it then into a StaticPolynomials.Polynomial for further computations."
},

{
    "location": "index.html#Tutorial-1",
    "page": "Introduction",
    "title": "Tutorial",
    "category": "section",
    "text": "import DynamicPolynomials: @polyvar\nusing StaticPolynomials: gradient\n\n@polyvar x y\n\njulia> f = Polynomial(x^2+3y^2*x+1) # the support of f is encoded in the `Polynomial` type.\nStaticPolynomials.Polynomial{Int64,2,SExponents{4103c6525e885f8b}}()\n\njulia> evaluate(f, [2.0, 3.0])\n59.0\njulia> gradient(f, [2.0, 3.0])\n2-element Array{Float64,1}:\n 31.0\n 36.0We also support systems of polynomials.julia> F = system([x^2+y^2+1, x + y - 5])\nStaticPolynomials.Systems.System2{Int64,2,SExponents{932bae602683cacb},SExponents{44c61f91039334d1}}()\njulia> evaluate(F, [2.0, 3.0])\n2-element Array{Float64,1}:\n 14.0\n  0.0\njulia> jacobian(f, [2.0, 3.0])\n2×2 Array{Float64,2}:\n 4.0  6.0\n 1.0  1.0"
},

{
    "location": "reference.html#",
    "page": "Reference",
    "title": "Reference",
    "category": "page",
    "text": ""
},

{
    "location": "reference.html#Reference-1",
    "page": "Reference",
    "title": "Reference",
    "category": "section",
    "text": ""
},

{
    "location": "reference.html#Polynomial-1",
    "page": "Reference",
    "title": "Polynomial",
    "category": "section",
    "text": "Polynomial\nSExponents\ncoefficients\nexponents\nnvariables(::Polynomial)\nnparameters(::Polynomial)\ncoefficienttype(::Polynomial)\nscale_coefficients!(::Polynomial, λ)\nevaluate(::Polynomial, ::AbstractVector)\ngradient(::Polynomial, ::AbstractVector)\ngradient(::Polynomial, ::AbstractVector, ::Any)\ngradient!(::AbstractVector, ::Polynomial, ::AbstractVector)\ngradient!(::AbstractVector, ::Polynomial, ::AbstractVector, ::Any)\nevaluate_and_gradient\nevaluate_and_gradient!\ndifferentiate_parameters(::Polynomial, ::Any, ::Any)\ndifferentiate_parameters!(::Any, ::Polynomial, ::Any, ::Any)"
},

{
    "location": "reference.html#Systems-of-Polynomials-1",
    "page": "Reference",
    "title": "Systems of Polynomials",
    "category": "section",
    "text": "PolynomialSystem\nnpolynomials(::PolynomialSystem)\nnvariables(::PolynomialSystem)\nnparameters(::PolynomialSystem)\nforeach(f::Function, ::PolynomialSystem)\nscale_coefficients!(::PolynomialSystem, ::AbstractVector)\nevaluate(::PolynomialSystem, ::AbstractVector)\nevaluate!(::AbstractVector, ::PolynomialSystem, ::AbstractVector)\nevaluate(::PolynomialSystem, ::AbstractVector, ::Any)\nevaluate!(::AbstractVector, ::PolynomialSystem, ::AbstractVector, ::Any)\njacobian\njacobian!\nevaluate_and_jacobian\nevaluate_and_jacobian!\ndifferentiate_parameters(::Any, ::PolynomialSystem, ::Any, ::Any)\ndifferentiate_parameters!(::Any, ::PolynomialSystem, ::Any, ::Any)"
},

]}
