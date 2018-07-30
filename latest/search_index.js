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
    "location": "reference.html#StaticPolynomials.Polynomial",
    "page": "Reference",
    "title": "StaticPolynomials.Polynomial",
    "category": "type",
    "text": "Polynomial{T, NVars, SE<:SExponents}\n\nA Polynomial with coefficents in T in NVars variables and exponents of type SE.\n\nPolynomial(f::MP.AbstractPolynomial, [variables])\n\nConstruct a Polynomial from f.\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.SExponents",
    "page": "Reference",
    "title": "StaticPolynomials.SExponents",
    "category": "type",
    "text": "SExponents{N}\n\nStore the exponents of the terms of a polynomial (the support) with N terms as an type. This results in an unique type for each possible support.\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.coefficients",
    "page": "Reference",
    "title": "StaticPolynomials.coefficients",
    "category": "function",
    "text": "coefficients(f)\n\nReturn the coefficients of f.\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.exponents",
    "page": "Reference",
    "title": "StaticPolynomials.exponents",
    "category": "function",
    "text": "exponents(::SExponents)\n\nConverts exponents stored in a SExponents to a matrix.\n\n\n\nexponents(f)\n\nReturn the exponents of f as an matrix where each column represents the exponents of a monomial.\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.nvariables-Tuple{StaticPolynomials.Polynomial}",
    "page": "Reference",
    "title": "StaticPolynomials.nvariables",
    "category": "method",
    "text": "nvariables(f::Polynomial)\n\nReturn the number of variables f.\n\n\n\nnvariables(F::AbstractSystem)\n\nThe number of variables of the system F.\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.coefficienttype-Tuple{StaticPolynomials.Polynomial}",
    "page": "Reference",
    "title": "StaticPolynomials.coefficienttype",
    "category": "method",
    "text": "coefficienttype(f::Polynomial)\n\nReturn the type of the coefficients of f.\n\n\n\ncoefficienttype(F::AbstractSystem)\n\nReturn the type of the coefficients of the polynomials of F.\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.scale_coefficients!-Tuple{StaticPolynomials.Polynomial,Any}",
    "page": "Reference",
    "title": "StaticPolynomials.scale_coefficients!",
    "category": "method",
    "text": "scale_coefficients!(f, λ)\n\nScale the coefficients of f by the factor λ.\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.evaluate-Tuple{StaticPolynomials.Polynomial,AbstractArray{T,1} where T}",
    "page": "Reference",
    "title": "StaticPolynomials.evaluate",
    "category": "method",
    "text": "evaluate(f::Polynomial, x)\n\nEvaluate the polynomial f at x.\n\n\n\n"
},

{
    "location": "reference.html#Base.LinAlg.gradient-Tuple{StaticPolynomials.Polynomial,AbstractArray{T,1} where T}",
    "page": "Reference",
    "title": "Base.LinAlg.gradient",
    "category": "method",
    "text": "gradient(f::Polynomial, x)\n\nEvaluate the gradient of the polynomial f at x.\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.gradient!-Tuple{AbstractArray{T,1} where T,StaticPolynomials.Polynomial,AbstractArray{T,1} where T}",
    "page": "Reference",
    "title": "StaticPolynomials.gradient!",
    "category": "method",
    "text": "gradient!(u, f::Polynomial, x)\n\nEvaluate the gradient of the polynomial f at x and store the result in u.\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.evaluate_and_gradient",
    "page": "Reference",
    "title": "StaticPolynomials.evaluate_and_gradient",
    "category": "function",
    "text": "evaluate_and_gradient(f::Polynomial, x)\n\nEvaluate the polynomial f and its gradient at x. Returns a tuple.\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.evaluate_and_gradient!",
    "page": "Reference",
    "title": "StaticPolynomials.evaluate_and_gradient!",
    "category": "function",
    "text": "evaluate_and_gradient!(u, f::Polynomial, x)\n\nEvaluate the polynomial f and its gradient at x. Stores the gradient in u and returns the f(x).\n\n\n\n"
},

{
    "location": "reference.html#Polynomial-1",
    "page": "Reference",
    "title": "Polynomial",
    "category": "section",
    "text": "Polynomial\nSExponents\ncoefficients\nexponents\nnvariables(::Polynomial)\ncoefficienttype(::Polynomial)\nscale_coefficients!(::Polynomial, λ)\nevaluate(::Polynomial, ::AbstractVector)\ngradient(::Polynomial, ::AbstractVector)\ngradient!(::AbstractVector, ::Polynomial, ::AbstractVector)\nevaluate_and_gradient\nevaluate_and_gradient!"
},

{
    "location": "reference.html#StaticPolynomials.AbstractSystem",
    "page": "Reference",
    "title": "StaticPolynomials.AbstractSystem",
    "category": "type",
    "text": " AbstractSystem{T, M, N}\n\nRepresents a system of M polynomials in N variables with coefficients in T.\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.system",
    "page": "Reference",
    "title": "StaticPolynomials.system",
    "category": "function",
    "text": "system(polys::AbstractVector{<:MP.AbstractPolynomial}..., variables=sorted_variables(polys))\nsystem(polys...)\n\nCreate a system of polynomials from the given polys. The result is an object which is a subtype of AbstractSystem. This function is by design not typestable.\n\nExample\n\njulia> import DynamicPolynomials: @polyvar\njulia> @polyvar x y\njulia> F = system(x^2+y^2+3, x-y+2, x^2+2y)\njulia> F isa AbstractSystem{Int64, 3, 2}\ntrue\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.nvariables-Tuple{StaticPolynomials.AbstractSystem}",
    "page": "Reference",
    "title": "StaticPolynomials.nvariables",
    "category": "method",
    "text": "nvariables(f::Polynomial)\n\nReturn the number of variables f.\n\n\n\nnvariables(F::AbstractSystem)\n\nThe number of variables of the system F.\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.npolynomials-Tuple{StaticPolynomials.AbstractSystem}",
    "page": "Reference",
    "title": "StaticPolynomials.npolynomials",
    "category": "method",
    "text": "npolynomials(F::AbstractSystem)\n\nThe number of polynomials of the system F.\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.coefficienttype-Tuple{StaticPolynomials.AbstractSystem}",
    "page": "Reference",
    "title": "StaticPolynomials.coefficienttype",
    "category": "method",
    "text": "coefficienttype(f::Polynomial)\n\nReturn the type of the coefficients of f.\n\n\n\ncoefficienttype(F::AbstractSystem)\n\nReturn the type of the coefficients of the polynomials of F.\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.scale_coefficients!-Tuple{StaticPolynomials.AbstractSystem,AbstractArray{T,1} where T}",
    "page": "Reference",
    "title": "StaticPolynomials.scale_coefficients!",
    "category": "method",
    "text": "scale_coefficients!(F::AbstractSystem{T, M}, λ::AbstractVector)\n\nScale the coefficients of the polynomials fᵢ of F by the factor λᵢ. λ needs to have have length M.\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.evaluate-Tuple{StaticPolynomials.AbstractSystem,AbstractArray{T,1} where T}",
    "page": "Reference",
    "title": "StaticPolynomials.evaluate",
    "category": "method",
    "text": "evaluate(F::AbstractSystem, x::AbstractVector)\n\nEvaluate the system F at x.\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.evaluate!-Tuple{AbstractArray{T,1} where T,StaticPolynomials.AbstractSystem,AbstractArray{T,1} where T}",
    "page": "Reference",
    "title": "StaticPolynomials.evaluate!",
    "category": "method",
    "text": "evaluate!(u, F::AbstractSystem, x)\n\nEvaluate the system F at x and store the result in u.\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.jacobian",
    "page": "Reference",
    "title": "StaticPolynomials.jacobian",
    "category": "function",
    "text": "jacobian(F::AbstractSystem, x)\njacobian(F::AbstractSystem, x::SVector)\n\nEvaluate the Jacobian of the system F at x.\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.jacobian!",
    "page": "Reference",
    "title": "StaticPolynomials.jacobian!",
    "category": "function",
    "text": "jacobian!(u, F::AbstractSystem, x)\n\nEvaluate the Jacobian of the system F at x and store the result in u.\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.evaluate_and_jacobian",
    "page": "Reference",
    "title": "StaticPolynomials.evaluate_and_jacobian",
    "category": "function",
    "text": "evaluate_and_jacobian(F::AbstractSystem, x)\nevaluate_and_jacobian(F::AbstractSystem, x::SVector)\n\nEvaluate the system F and its Jacobian at x.\n\n\n\n"
},

{
    "location": "reference.html#StaticPolynomials.evaluate_and_jacobian!",
    "page": "Reference",
    "title": "StaticPolynomials.evaluate_and_jacobian!",
    "category": "function",
    "text": "evaluate_and_jacobian!(u, U, F::AbstractSystem, x)\n\nEvaluate the system F and its Jacobian at x and store the results in u (evalution) and U (Jacobian).\n\n\n\n"
},

{
    "location": "reference.html#Base.foreach-Tuple{Function,StaticPolynomials.AbstractSystem}",
    "page": "Reference",
    "title": "Base.foreach",
    "category": "method",
    "text": "foreach(f, F::AbstractSystem)\n\nIterate over the polynomials of F and apply f to each polynomial.\n\n\n\n"
},

{
    "location": "reference.html#Systems-of-Polynomials-1",
    "page": "Reference",
    "title": "Systems of Polynomials",
    "category": "section",
    "text": "AbstractSystem\nsystem\nnvariables(::AbstractSystem)\nnpolynomials(::AbstractSystem)\ncoefficienttype(::AbstractSystem)\nscale_coefficients!(::AbstractSystem, ::AbstractVector)\nevaluate(::AbstractSystem, ::AbstractVector)\nevaluate!(::AbstractVector, ::AbstractSystem, ::AbstractVector)\njacobian\njacobian!\nevaluate_and_jacobian\nevaluate_and_jacobian!\nforeach(f::Function, ::AbstractSystem)"
},

]}
