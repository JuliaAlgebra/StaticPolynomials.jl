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
    "text": "StaticPolynomials.jl is a library for fast evaluation of multivariate polynomials. It achieves it speed by automatically generating and compiling high performance code for the evaluation of the polynomial and it\'s derivatives. This is made possible by encoding in the type signature which terms exists and Julia\'s metaprogramming capabilities (in particular generated functions).A tradeoff of this is approach is that for each polynomial (unless only coefficients changes) new functions have to be compiled. Therefore this is usually only a good idea if you have to evaluate the same polynomial (system) very often.Since the polynomials in this package are optimised for fast evaluation they are not suited for the usual polynomial arithmetic. It is recommended to construct a polynomial with an implementation of MultivariatePolynomials.jl, e.g. DynamicPolynomials.jl, and to convert them into a Polynomial for the evaluations."
},

{
    "location": "index.html#Performance-1",
    "page": "Introduction",
    "title": "Performance",
    "category": "section",
    "text": "StaticPolynomials is substantially faster than automatic differentiation packages like ForwardDiff, also works for complex polynomials and often outperforms hand tuned gradients.using StaticPolynomials, BenchmarkTools, StaticArrays\nimport ForwardDiff\nimport DynamicPolynomials: @polyvar\n\n# Our real-world test polynomial\nfunction f10(x)\n    f  = 48*x[1]^3 + 72*x[1]^2*x[2] + 72*x[1]^2*x[3] + 72*x[1]^2*x[4] + 72*x[1]^2*x[5] + 72*x[1]^2*x[7]\n    f += 72*x[1]^2*x[8] + 72*x[1]*x[2]^2 + 144*x[1]*x[2]*x[4] + 144*x[1]*x[2]*x[7] + 72*x[1]*x[3]^2\n    f += 144*x[1]*x[3]*x[5] + 144*x[1]*x[3]*x[8] + 72*x[1]*x[4]^2 + 144*x[1]*x[4]*x[7] + 72*x[1]*x[5]^2\n    f += 144*x[1]*x[5]*x[8] + 72*x[1]*x[7]^2 + 72*x[1]*x[8]^2 + 48*x[2]^3 + 72*x[2]^2*x[3]\n    f += 72*x[2]^2*x[4] + 72*x[2]^2*x[6] + 72*x[2]^2*x[7] + 72*x[2]^2*x[9] + 72*x[2]*x[3]^2\n    f += 144*x[2]*x[3]*x[6] + 144*x[2]*x[3]*x[9] + 72*x[2]*x[4]^2 + 144*x[2]*x[4]*x[7] + 72*x[2]*x[6]^2\n    f += 144*x[2]*x[6]*x[9] + 72*x[2]*x[7]^2 + 72*x[2]*x[9]^2 + 48*x[3]^3 + 72*x[3]^2*x[5]\n    f += 72*x[3]^2*x[6] + 72*x[3]^2*x[8] + 72*x[3]^2*x[9] + 72*x[3]*x[5]^2 + 144*x[3]*x[5]*x[8]\n    f += 72*x[3]*x[6]^2 + 144*x[3]*x[6]*x[9] + 72*x[3]*x[8]^2 + 72*x[3]*x[9]^2 + 48*x[4]^3\n    f += 72*x[4]^2*x[5] + 72*x[4]^2*x[6] + 72*x[4]^2*x[7] + 72*x[4]^2*x[10] + 72*x[4]*x[5]^2\n    f += 144*x[4]*x[5]*x[6] + 144*x[4]*x[5]*x[10] + 72*x[4]*x[6]^2 + 144*x[4]*x[6]*x[10] + 72*x[4]*x[7]^2\n    f += 72*x[4]*x[10]^2 + 48*x[5]^3 + 72*x[5]^2*x[6] + 72*x[5]^2*x[8] + 72*x[5]^2*x[10]\n    f += 72*x[5]*x[6]^2 + 144*x[5]*x[6]*x[10] + 72*x[5]*x[8]^2 + 72*x[5]*x[10]^2 + 48*x[6]^3\n    f += 72*x[6]^2*x[9] + 72*x[6]^2*x[10] + 72*x[6]*x[9]^2 + 72*x[6]*x[10]^2 + 48*x[7]^3\n    f += 72*x[7]^2*x[8] + 72*x[7]^2*x[9] + 72*x[7]^2*x[10] + 72*x[7]*x[8]^2 + 144*x[7]*x[8]*x[9]\n    f += 144*x[7]*x[8]*x[10] + 72*x[7]*x[9]^2 + 144*x[7]*x[9]*x[10] + 72*x[7]*x[10]^2 + 48*x[8]^3\n    f += 72*x[8]^2*x[9] + 72*x[8]^2*x[10] + 72*x[8]*x[9]^2 + 144*x[8]*x[9]*x[10] + 72*x[8]*x[10]^2\n    f += 48*x[9]^3 + 72*x[9]^2*x[10] + 72*x[9]*x[10]^2 + 48*x[10]^3\n    return f\nend\n\n# setup polynomial\n@polyvar x[1:10]\np10 = Polynomial(f10(x))\n\nx = @SVector rand(10)\n\n@btime f10($x) # 31.778 ns (0 allocations: 0 bytes)\n@btime $p10($x) # 28.836 ns (0 allocations: 0 bytes)\n\n@btime gradient($p10, $x) # 72.334 ns (0 allocations: 0 bytes)\ncfg = ForwardDiff.GradientConfig(f10, y)\n@btime ForwardDiff.gradient($f10, $y, $cfg) # 550.187 ns (2 allocations: 192 bytes)"
},

{
    "location": "index.html#Short-introduction-1",
    "page": "Introduction",
    "title": "Short introduction",
    "category": "section",
    "text": "julia> import DynamicPolynomials: @polyvar;\njulia> using StaticPolynomials: gradient;\n\njulia> @polyvar x y a;\n\njulia> f = Polynomial(x^2+3y^2*x+1)\n1 + x² + 3xy²\n\njulia> evaluate(f, [2, 3])\n59\n\njulia> gradient(f, [2, 3])\n2-element Array{Int64,1}:\n 31\n 36\n\n# You can also declare certain variables as parameters\njulia> g = Polynomial(x^2+3y^2*x+a^2; parameters=[a])\na² + x² + 3xy²\n\njulia> evaluate(g, [2, 3], [4])\n74\njulia> gradient(g, [2, 3], [4])\n2-element Array{Int64,1}:\n 31\n 36\n\n# You can also differentiate with respect to the parameters\njulia> differentiate_parameters(g, [2, 3], [4])\n1-element Array{Int64,1}:\n 8We also support systems of polynomials.julia> @polyvar x y a b;\n\njulia> F = PolynomialSystem([x^2+y^2+1, x + y - 5])\nPolynomialSystem{2, 2, 0}:\n 1 + x² + y²\n\n -5 + x + y\n\njulia> evaluate(F, [2, 3])\n2-element Array{Int64,1}:\n 14\n  0\n\njulia> jacobian(F, [2, 3])\n2×2 Array{Int64,2}:\n 4  6\n 1  1\n\n# You can also declare parameters\njulia> G = PolynomialSystem([x^2+y^2+a^3, b*x + y - 5]; parameters=[a, b])\nPolynomialSystem{2, 2, 2}:\n a³ + x² + y²\n\n -5 + xb + y\n\njulia> evaluate(G, [2, 3], [-2, 4])\n2-element Array{Int64,1}:\n  5\n  6\n\njulia> jacobian(G, [2, 3], [-2, 4])\n2×2 Array{Int64,2}:\n  4  6\n  4  1\n\n# You can also differentiate with respect to the parameters\njulia> differentiate_parameters(G, [2, 3], [-2, 4])\n2×2 Array{Int64,2}:\n  12  0\n   0  2"
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
