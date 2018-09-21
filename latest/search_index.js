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
    "text": "julia> import DynamicPolynomials: @polyvar;\njulia> using StaticPolynomials: gradient;\n\njulia> @polyvar x y a;\n\njulia> f = Polynomial(x^2+3y^2*x+1)\n1 + x² + 3xy²\n\njulia> evaluate(f, [2, 3])\n59\n\njulia> gradient(f, [2, 3])\n2-element Array{Int64,1}:\n 31\n 36\n\n# You can also declare certain variables as parameters\njulia> g = Polynomial(x^2+3y^2*x+a^2; parameters=[a])\na² + x² + 3xy²\n\njulia> evaluate(g, [2, 3], [4])\n74\njulia> gradient(g, [2, 3], [4.0])\n2-element Array{Int64,1}:\n 31\n 36We also support systems of polynomials.julia> @polyvar x y a b;\n\njulia> F = PolynomialSystem([x^2+y^2+1, x + y - 5])\nPolynomialSystem{2, 2, 0}:\n 1 + x² + y²\n\n -5 + x + y\n\njulia> evaluate(F, [2, 3])\n2-element Array{Int64,1}:\n 14\n  0\n\njulia> jacobian(F, [2, 3])\n2×2 Array{Int64,2}:\n 4  6\n 1  1\n\n# You can also declare parameters\njulia> G = PolynomialSystem([x^2+y^2+a^3, b*x + y - 5]; parameters=[a, b])\nPolynomialSystem{2, 2, 2}:\n a³ + x² + y²\n\n -5 + xb + y\n\njulia> evaluate(G, [2, 3], [-2, 4])\n2-element Array{Int64,1}:\n  5\n  6\n\njulia> jacobian(G, [2, 3], [-2, 4])\n2×2 Array{Int64,2}:\n  4  6\n  4  1\n\n# You can also differentiate with respect to the parameters\njulia> differentiate_parameters(G, [2, 3], [-2, 4])\n2×2 Array{Int64,2}:\n  12  0\n   0  2"
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
    "location": "reference.html#StaticPolynomials.Polynomial",
    "page": "Reference",
    "title": "StaticPolynomials.Polynomial",
    "category": "type",
    "text": "Polynomial{T, SE<:SExponents}\n\nA Polynomial with coefficents in T in NVars variables and exponents of type SE.\n\nPolynomial(f::MP.AbstractPolynomial, [variables])\n\nConstruct a Polynomial from f.\n\n\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.SExponents",
    "page": "Reference",
    "title": "StaticPolynomials.SExponents",
    "category": "type",
    "text": "SExponents{N}\n\nStore the exponents of the terms of a polynomial (the support) with N terms as an type. This results in an unique type for each possible support.\n\n\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.coefficients",
    "page": "Reference",
    "title": "StaticPolynomials.coefficients",
    "category": "function",
    "text": "coefficients(f)\n\nReturn the coefficients of f.\n\n\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.exponents",
    "page": "Reference",
    "title": "StaticPolynomials.exponents",
    "category": "function",
    "text": "exponents(::SExponents)\n\nConverts exponents stored in a SExponents to a matrix.\n\n\n\n\n\nexponents(f)\n\nReturn the exponents of f as an matrix where each column represents the exponents of a monomial.\n\n\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.nvariables-Tuple{Polynomial}",
    "page": "Reference",
    "title": "StaticPolynomials.nvariables",
    "category": "method",
    "text": "nvariables(f::Polynomial)\n\nReturn the number of variables of f.\n\n\n\n\n\nnvariables(F::AbstractSystem)\n\nThe number of variables of the system F.\n\n\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.nparameters-Tuple{Polynomial}",
    "page": "Reference",
    "title": "StaticPolynomials.nparameters",
    "category": "method",
    "text": "nparameters(f::Polynomial)\n\nReturn the number of parameters of f.\n\n\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.coefficienttype-Tuple{Polynomial}",
    "page": "Reference",
    "title": "StaticPolynomials.coefficienttype",
    "category": "method",
    "text": "coefficienttype(f::Polynomial)\n\nReturn the type of the coefficients of f.\n\n\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.scale_coefficients!-Tuple{Polynomial,Any}",
    "page": "Reference",
    "title": "StaticPolynomials.scale_coefficients!",
    "category": "method",
    "text": "scale_coefficients!(f, λ)\n\nScale the coefficients of f by the factor λ.\n\n\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.evaluate-Tuple{Polynomial,Any}",
    "page": "Reference",
    "title": "StaticPolynomials.evaluate",
    "category": "method",
    "text": "evaluate(f::Polynomial, x)\n\nEvaluate the polynomial f at x.\n\n\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.evaluate-Tuple{Polynomial,Any,Any}",
    "page": "Reference",
    "title": "StaticPolynomials.evaluate",
    "category": "method",
    "text": "evaluate(f::Polynomial, x, p)\n\nEvaluate f at x with parameters p.\n\n\n\n\n\n"
},

{
    "location": "reference.html#LinearAlgebra.gradient",
    "page": "Reference",
    "title": "LinearAlgebra.gradient",
    "category": "function",
    "text": "gradient(f::Polynomial, x)\n\nEvaluate the gradient of the polynomial f at x.\n\n\n\n\n\ngradient(f::Polynomial, x, p)\n\nEvaluate the gradient of the polynomial f at x with parameters p.\n\n\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.gradient!",
    "page": "Reference",
    "title": "StaticPolynomials.gradient!",
    "category": "function",
    "text": "gradient!(u, f::Polynomial, x)\n\nEvaluate the gradient of the polynomial f at x and store the result in u.\n\ngradient!(u, f::Polynomial, x, p)\n\nEvaluate the gradient of the polynomial f at x with parameters p and store the result in u.\n\n\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.evaluate_and_gradient",
    "page": "Reference",
    "title": "StaticPolynomials.evaluate_and_gradient",
    "category": "function",
    "text": "evaluate_and_gradient(f::Polynomial, x)\n\nEvaluate the polynomial f and its gradient at x. Returns a tuple.\n\nevaluate_and_gradient(f::Polynomial, x, p)\n\nEvaluate the polynomial f and its gradient at x with parameters p. Returns a tuple.\n\n\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.evaluate_and_gradient!",
    "page": "Reference",
    "title": "StaticPolynomials.evaluate_and_gradient!",
    "category": "function",
    "text": "evaluate_and_gradient!(u, f::Polynomial, x)\n\nEvaluate the polynomial f and its gradient at x. Stores the gradient in u and returns the f(x).\n\nevaluate_and_gradient!(u, f::Polynomial, x, p)\n\nEvaluate the polynomial f and its gradient at x with parameters p. Stores the gradient in u and returns the f(x).\n\n\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.differentiate_parameters-Tuple{Polynomial,Any,Any}",
    "page": "Reference",
    "title": "StaticPolynomials.differentiate_parameters",
    "category": "method",
    "text": "differentiate_parameters(f::Polynomial, x, p)\n\nEvaluate the gradient of the polynomial f w.r.t. the parameters at x with parameters p.\n\n\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.differentiate_parameters!-Tuple{Any,Polynomial,Any,Any}",
    "page": "Reference",
    "title": "StaticPolynomials.differentiate_parameters!",
    "category": "method",
    "text": "differentiate_parameters!(u, f::Polynomial, x, p)\n\nEvaluate the gradient of the polynomial f w.r.t. the parameters at x with parameters p and store the result in u.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Polynomial-1",
    "page": "Reference",
    "title": "Polynomial",
    "category": "section",
    "text": "Polynomial\nSExponents\ncoefficients\nexponents\nnvariables(::Polynomial)\nnparameters(::Polynomial)\ncoefficienttype(::Polynomial)\nscale_coefficients!(::Polynomial, λ)\nevaluate(::Polynomial, x)\nevaluate(::Polynomial, x, p)\ngradient\ngradient!\nevaluate_and_gradient\nevaluate_and_gradient!\ndifferentiate_parameters(::Polynomial, x, p)\ndifferentiate_parameters!(u, ::Polynomial, x, p)"
},

{
    "location": "reference.html#StaticPolynomials.PolynomialSystem",
    "page": "Reference",
    "title": "StaticPolynomials.PolynomialSystem",
    "category": "type",
    "text": "PolynomialSystem{N, NVars, NParams, <:Tuple}\n\nA polynomial system of N polynomials in NVars variables with NParams variables.\n\nConstructors:\n\nPolynomialSystem(polys::AbstractVector{<:MP.AbstractPolynomial}; variables=MP.variables(polys), parameters=nothing)\nPolynomialSystem(polys::MP.AbstractPolynomial...; kwargs...)\n\nCreate a system of polynomials from the given polynomials polys. This function is by design not typestable.\n\nExample\n\njulia> import DynamicPolynomials: @polyvar\njulia> @polyvar x y a\njulia> PolynomialSystem(x^2+y^2+3, x-y+2, x^2+2y+a; parameters=[a])\nPolynomialSystem{3, 2}:\n 3 + x² + y²\n\n 2 + x - y\n\n x² + 2y\n\n\n\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.npolynomials-Tuple{PolynomialSystem}",
    "page": "Reference",
    "title": "StaticPolynomials.npolynomials",
    "category": "method",
    "text": "npolynomials(F::AbstractSystem)\n\nThe number of polynomials of the system F.\n\n\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.nvariables-Tuple{PolynomialSystem}",
    "page": "Reference",
    "title": "StaticPolynomials.nvariables",
    "category": "method",
    "text": "nvariables(f::Polynomial)\n\nReturn the number of variables of f.\n\n\n\n\n\nnvariables(F::AbstractSystem)\n\nThe number of variables of the system F.\n\n\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.nparameters-Tuple{PolynomialSystem}",
    "page": "Reference",
    "title": "StaticPolynomials.nparameters",
    "category": "method",
    "text": "nparameters(F::AbstractSystem)\n\nThe number of parameters of the system F.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Base.foreach-Tuple{Function,PolynomialSystem}",
    "page": "Reference",
    "title": "Base.foreach",
    "category": "method",
    "text": "foreach(f, F::AbstractSystem)\n\nIterate over the polynomials of F and apply f to each polynomial.\n\n\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.scale_coefficients!-Tuple{PolynomialSystem,AbstractArray{T,1} where T}",
    "page": "Reference",
    "title": "StaticPolynomials.scale_coefficients!",
    "category": "method",
    "text": "scale_coefficients!(F::AbstractSystem{T, M}, λ::AbstractVector)\n\nScale the coefficients of the polynomials fᵢ of F by the factor λᵢ. λ needs to have have length M.\n\n\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.evaluate-Tuple{PolynomialSystem,Any}",
    "page": "Reference",
    "title": "StaticPolynomials.evaluate",
    "category": "method",
    "text": " evaluate(F::PolynomialSystem, x)\n\nEvaluate the polynomial system F at x.\n\n\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.evaluate-Tuple{PolynomialSystem,AbstractArray{T,1} where T,Any}",
    "page": "Reference",
    "title": "StaticPolynomials.evaluate",
    "category": "method",
    "text": " evaluate(F::PolynomialSystem, x, p)\n\nEvaluate the polynomial system F at x with parameters p.\n\n\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.evaluate!-Tuple{Any,PolynomialSystem,Any}",
    "page": "Reference",
    "title": "StaticPolynomials.evaluate!",
    "category": "method",
    "text": " evaluate!(u, F::PolynomialSystem, x)\n\nEvaluate the polynomial system F at x and store its result in u.\n\n\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.evaluate!-Tuple{Any,PolynomialSystem,Any,Any}",
    "page": "Reference",
    "title": "StaticPolynomials.evaluate!",
    "category": "method",
    "text": " evaluate!(u, F::PolynomialSystem, x, p)\n\nEvaluate the polynomial system F at x with parameters p and store its result in u.\n\n\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.jacobian",
    "page": "Reference",
    "title": "StaticPolynomials.jacobian",
    "category": "function",
    "text": " jacobian(F::PolynomialSystem, x)\n\nEvaluate the Jacobian of the polynomial system F at x.\n\n\n\n\n\n jacobian(F::PolynomialSystem, x, p)\n\nEvaluate the Jacobian of the polynomial system F at x with parameters p.\n\n\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.jacobian!",
    "page": "Reference",
    "title": "StaticPolynomials.jacobian!",
    "category": "function",
    "text": " jacobian!(U, F::PolynomialSystem, x)\n\nEvaluate the Jacobian of the polynomial system F at x and store its result in U.\n\n\n\n\n\n jacobian(U, F::PolynomialSystem, x, p)\n\nEvaluate the Jacobian of the polynomial system F at x with parameters p and store its result in U.\n\n\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.evaluate_and_jacobian",
    "page": "Reference",
    "title": "StaticPolynomials.evaluate_and_jacobian",
    "category": "function",
    "text": "evaluate_and_jacobian!(F::PolynomialSystem, x, p)\n\nEvaluate the system F and its Jacobian at x with parameters p.\n\n\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.evaluate_and_jacobian!",
    "page": "Reference",
    "title": "StaticPolynomials.evaluate_and_jacobian!",
    "category": "function",
    "text": "evaluate_and_jacobian!(u, U, F::PolynomialSystem, x)\n\nEvaluate the system F and its Jacobian at x and store the results in u (evalution) and U (Jacobian).\n\n\n\n\n\nevaluate_and_jacobian!(u, U, F::PolynomialSystem, x, p)\n\nEvaluate the system F and its Jacobian at x with parameters p and store the results in u (evalution) and U (Jacobian).\n\n\n\n\n\nevaluate_and_jacobian(F::PolynomialSystem, x)\n\nEvaluate the system F and its Jacobian at x.\n\n\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.differentiate_parameters-Tuple{PolynomialSystem,Any,Any}",
    "page": "Reference",
    "title": "StaticPolynomials.differentiate_parameters",
    "category": "method",
    "text": " differentiate_parameters(F::PolynomialSystem, x, p)\n\nEvaluate the derivative of the polynomial system F at x with parameters p with respect to the parameters and store the result in U.\n\n\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.differentiate_parameters!-Tuple{Any,PolynomialSystem,Any,Any}",
    "page": "Reference",
    "title": "StaticPolynomials.differentiate_parameters!",
    "category": "method",
    "text": " differentiate_parameters!(U, F::PolynomialSystem, x, p)\n\nEvaluate the derivative of the polynomial system F at x with parameters p with respect to the parameters and store the result in U.\n\n\n\n\n\n"
},

{
    "location": "reference.html#Systems-of-Polynomials-1",
    "page": "Reference",
    "title": "Systems of Polynomials",
    "category": "section",
    "text": "PolynomialSystem\nnpolynomials(::PolynomialSystem)\nnvariables(::PolynomialSystem)\nnparameters(::PolynomialSystem)\nforeach(f::Function, ::PolynomialSystem)\nscale_coefficients!(::PolynomialSystem, ::AbstractVector)\nevaluate(::PolynomialSystem, x)\nevaluate(::PolynomialSystem, ::AbstractVector, ::Any)\nevaluate!(u, ::PolynomialSystem, x)\nevaluate!(u, ::PolynomialSystem, x, p)\njacobian\njacobian!\nevaluate_and_jacobian\nevaluate_and_jacobian!\ndifferentiate_parameters(::PolynomialSystem, x, p)\ndifferentiate_parameters!(U, ::PolynomialSystem, x, p)"
},

]}
