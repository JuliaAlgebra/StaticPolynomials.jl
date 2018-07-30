using DynamicPolynomials: @polyvar
using StaticPolynomials, StaticArrays, BenchmarkTools




@polyvar Q1 Q2 Q3 Q4 Q5 Q6

f = Polynomial((Q3^2 - Q4^2) * (Q4^2 - Q2^2) * (Q2^2 - Q3^2) * Q5 * (3*Q6^2 - Q5^2), [Q1 Q2 Q3 Q4 Q5 Q6])
q3(Q) = (Q[3]^2 - Q[4]^2) * (Q[4]^2 - Q[2]^2) * (Q[2]^2 - Q[3]^2) * Q[5] * (3*Q[6]^2 - Q[5]^2)

Q = rand(6)

@btime StaticPolynomials.evaluate($f, $Q)

@btime q3($Q)


INV6Q = StaticPolynomials.system(
   [  Q1,
      Q2^2 + Q3^2 + Q4^2,
      Q2 * Q3 * Q4,
      Q3^2 * Q4^2 + Q2^2 * Q4^2 + Q2^2 * Q3^2,
      Q5^2 + Q6^2,
      Q6^3 - 3*Q5^2 * Q6,
      1.0,
      Q6 * (2*Q2^2 - Q3^2 - Q4^2) + √3 * Q5 * (Q3^2 - Q4^2),
      (Q6^2 - Q5^2) * (2*Q2^2 - Q3^2 - Q4^2) - 2 * √3 * Q5 * Q6 * (Q3^2 - Q4^2),
      Q6 * (2*Q3^2 * Q4^2 - Q2^2 * Q4^2 - Q2^2 * Q3^2) + √3 * Q2 * (Q2^2 * Q4^2 - Q2^2 * Q3^2),
      (Q6^2 - Q5^2)*(2*Q3^2*Q4^2 - Q2^2*Q4^2 -Q2^2*Q3^2) - 2*√3 * Q5 * Q6 * (Q2^2*Q4^2 - Q2^2*Q3^2),
      (Q3^2 - Q4^2) * (Q4^2 - Q2^2) * (Q2^2 - Q3^2) * Q5 * (3*Q6^2 - Q5^2)
   ])

StaticPolynomials.evaluate_impl(typeof(INV6Q.f11), true)

struct TestPoly{T}
    coefficients::Vector{T}
end

struct STestPoly{T, N}
    coefficients::SVector{N, T}
end


function f11(f, x)
    c = f.coefficients
    x2 = x[2]
    x2_2 = x2 * x2
    x3 = x[3]
     @inbounds out = begin
        c1357 = c[1] * x2_2 * (x[3] * x[3])
        c1358 = c[2] * x2_2
        c1359 = c[3]
        c1360 = @evalpoly(x[3], c1358, zero(Float64), c1359)
        c1361 = @evalpoly(x[4], c1357, zero(Float64), c1360)
        c1362 = @evalpoly(x[5], zero(Float64), zero(Float64), c1361)
        c1363 = c[4] * x2_2 * (x[3] * x[3])
        c1364 = c[5] * x2_2
        c1365 = @evalpoly(x[4], c1363, zero(Float64), c1364)
        c1366 = @evalpoly(x[5], zero(Float64), c1365)
        c1367 = c[6] * x2_2 * (x[3] * x[3])
        c1368 = c[7] * x2_2
        c1369 = c[8]
        c1370 = @evalpoly(x[3], c1368, zero(Float64), c1369)
        c1371 = @evalpoly(x[4], c1367, zero(Float64), c1370)
        c1372 = c1371
        @evalpoly x[6] c1362 c1366 c1372
    end
    out
end
poly = TestPoly(c)
spoly = STestPoly(SVector{8}(c))
x = rand(6)

@btime f11($poly, $x)
@btime f11($spoly, $x)

@btime StaticPolynomials.evaluate($INV6Q.f2, $Q)



f3(r::SVector{3}) = SVector(
         r[1] + r[2] + r[3],
         r[1]*r[2] + r[2]*r[3] + r[1]*r[3],
         r[1]*r[2]*r[3] )
f4(r::SVector{4}) = SVector(
         r[1] + r[2] + r[3] + r[4],
         r[1]*r[2] + (r[1]*r[3] + r[1]*r[4] + r[2]*r[3] + r[2]*r[4] + r[3]*r[4]),
         r[1]*r[2]*r[3] + (r[1]*r[2]*r[4] + r[1]*r[3]*r[4] + r[2]*r[3]*r[4]),
         r[1]*r[2]*r[3]*r[4] )

@polyvar r1 r2 r3 r4
P3 = system([   r1 + r2 + r3,
                  r1*r2 + r2*r3 + r1*r3,
                  r1*r2*r3 ])
P4 = system([ r1 + r2 + r3 + r4,
               r1*r2 + r1*r3 + r1*r4 + r2*r3 + r2*r4 + r3*r4,
              r1*r2*r3 + r1*r2*r4 + r1*r3*r4 + r2*r3*r4,
              r1*r2*r3*r4   ])

@polyvar x1 x2 x3 x4 x5 x6 x7 x8 x9 x10
p10 = Polynomial(
 48*x1^3 + 72*x1^2*x2 + 72*x1^2*x3 + 72*x1^2*x4 + 72*x1^2*x5 + 72*x1^2*x7 +
 72*x1^2*x8 + 72*x1*x2^2 + 144*x1*x2*x4 + 144*x1*x2*x7 + 72*x1*x3^2 +
 144*x1*x3*x5 + 144*x1*x3*x8 + 72*x1*x4^2 + 144*x1*x4*x7 + 72*x1*x5^2 +
 144*x1*x5*x8 + 72*x1*x7^2 + 72*x1*x8^2 + 48*x2^3 + 72*x2^2*x3 +
 72*x2^2*x4 + 72*x2^2*x6 + 72*x2^2*x7 + 72*x2^2*x9 + 72*x2*x3^2 +
 144*x2*x3*x6 + 144*x2*x3*x9 + 72*x2*x4^2 + 144*x2*x4*x7 + 72*x2*x6^2 +
 144*x2*x6*x9 + 72*x2*x7^2 + 72*x2*x9^2 + 48*x3^3 + 72*x3^2*x5 +
 72*x3^2*x6 + 72*x3^2*x8 + 72*x3^2*x9 + 72*x3*x5^2 + 144*x3*x5*x8 +
 72*x3*x6^2 + 144*x3*x6*x9 + 72*x3*x8^2 + 72*x3*x9^2 + 48*x4^3 +
 72*x4^2*x5 + 72*x4^2*x6 + 72*x4^2*x7 + 72*x4^2*x10 + 72*x4*x5^2 +
 144*x4*x5*x6 + 144*x4*x5*x10 + 72*x4*x6^2 + 144*x4*x6*x10 + 72*x4*x7^2 +
 72*x4*x10^2 + 48*x5^3 + 72*x5^2*x6 + 72*x5^2*x8 + 72*x5^2*x10 +
 72*x5*x6^2 + 144*x5*x6*x10 + 72*x5*x8^2 + 72*x5*x10^2 + 48*x6^3 +
 72*x6^2*x9 + 72*x6^2*x10 + 72*x6*x9^2 + 72*x6*x10^2 + 48*x7^3 +
 72*x7^2*x8 + 72*x7^2*x9 + 72*x7^2*x10 + 72*x7*x8^2 + 144*x7*x8*x9 +
 144*x7*x8*x10 + 72*x7*x9^2 + 144*x7*x9*x10 + 72*x7*x10^2 + 48*x8^3 +
 72*x8^2*x9 + 72*x8^2*x10 + 72*x8*x9^2 + 144*x8*x9*x10 + 72*x8*x10^2 +
                 48*x9^3 + 72*x9^2*x10 + 72*x9*x10^2 + 48*x10^3 )

function f10(x)
    f  = 48*x[1]^3 + 72*x[1]^2*x[2] + 72*x[1]^2*x[3] + 72*x[1]^2*x[4] + 72*x[1]^2*x[5] + 72*x[1]^2*x[7]
    f += 72*x[1]^2*x[8] + 72*x[1]*x[2]^2 + 144*x[1]*x[2]*x[4] + 144*x[1]*x[2]*x[7] + 72*x[1]*x[3]^2
    f += 144*x[1]*x[3]*x[5] + 144*x[1]*x[3]*x[8] + 72*x[1]*x[4]^2 + 144*x[1]*x[4]*x[7] + 72*x[1]*x[5]^2
    f += 144*x[1]*x[5]*x[8] + 72*x[1]*x[7]^2 + 72*x[1]*x[8]^2 + 48*x[2]^3 + 72*x[2]^2*x[3]
    f += 72*x[2]^2*x[4] + 72*x[2]^2*x[6] + 72*x[2]^2*x[7] + 72*x[2]^2*x[9] + 72*x[2]*x[3]^2
    f += 144*x[2]*x[3]*x[6] + 144*x[2]*x[3]*x[9] + 72*x[2]*x[4]^2 + 144*x[2]*x[4]*x[7] + 72*x[2]*x[6]^2
    f += 144*x[2]*x[6]*x[9] + 72*x[2]*x[7]^2 + 72*x[2]*x[9]^2 + 48*x[3]^3 + 72*x[3]^2*x[5]
    f += 72*x[3]^2*x[6] + 72*x[3]^2*x[8] + 72*x[3]^2*x[9] + 72*x[3]*x[5]^2 + 144*x[3]*x[5]*x[8]
    f += 72*x[3]*x[6]^2 + 144*x[3]*x[6]*x[9] + 72*x[3]*x[8]^2 + 72*x[3]*x[9]^2 + 48*x[4]^3
    f += 72*x[4]^2*x[5] + 72*x[4]^2*x[6] + 72*x[4]^2*x[7] + 72*x[4]^2*x[10] + 72*x[4]*x[5]^2
    f += 144*x[4]*x[5]*x[6] + 144*x[4]*x[5]*x[10] + 72*x[4]*x[6]^2 + 144*x[4]*x[6]*x[10] + 72*x[4]*x[7]^2
    f += 72*x[4]*x[10]^2 + 48*x[5]^3 + 72*x[5]^2*x[6] + 72*x[5]^2*x[8] + 72*x[5]^2*x[10]
    f += 72*x[5]*x[6]^2 + 144*x[5]*x[6]*x[10] + 72*x[5]*x[8]^2 + 72*x[5]*x[10]^2 + 48*x[6]^3
    f += 72*x[6]^2*x[9] + 72*x[6]^2*x[10] + 72*x[6]*x[9]^2 + 72*x[6]*x[10]^2 + 48*x[7]^3
    f += 72*x[7]^2*x[8] + 72*x[7]^2*x[9] + 72*x[7]^2*x[10] + 72*x[7]*x[8]^2 + 144*x[7]*x[8]*x[9]
    f += 144*x[7]*x[8]*x[10] + 72*x[7]*x[9]^2 + 144*x[7]*x[9]*x[10] + 72*x[7]*x[10]^2 + 48*x[8]^3
    f += 72*x[8]^2*x[9] + 72*x[8]^2*x[10] + 72*x[8]*x[9]^2 + 144*x[8]*x[9]*x[10] + 72*x[8]*x[10]^2
    f += 48*x[9]^3 + 72*x[9]^2*x[10] + 72*x[9]*x[10]^2 + 48*x[10]^3
    return f
 end

StaticPolynomials.evaluate_impl(typeof(p10), false)

x = @SVector rand(10)
@btime StaticPolynomials.evaluate($p10, $x)
@btime f10($x)
@btime StaticPolynomials.gradient($p10, $x)
@btime StaticPolynomials.evaluate_and_gradient($p10, $x)


f2(r) = r[1]*r[2] + (r[1]*r[3] + r[1]*r[4] + r[2]*r[3] + r[2]*r[4] + r[3]*r[4])

r_3 = @SVector rand(3)
r_4 = rand(4)

@btime f3($r_3)     1.871 ns (0 allocations: 0 bytes)
@btime StaticPolynomials.evaluate($P3, $r_3)    15.597 ns (0 allocations: 0 bytes)
@btime StaticPolynomials.inline_evaluate($P3, $r_3)    11.098 ns (0 allocations: 0 bytes)
@btime f4($r_4)         8.719 ns
@btime StaticPolynomials.evaluate($P4, $r_4)    24.174 ns (0 allocations: 0 bytes)
@btime StaticPolynomials.inline_evaluate($P4, $r_4)    14.211 ns (0 allocations: 0 bytes)

StaticPolynomials.jacobian(P4, r_4)
@btime StaticPolynomials.jacobian($P4, $r_4)

p4_f2 = P4.f2
@btime StaticPolynomials.inline_evaluate($p4_f2, $r_4)

@btime f2($r_4)


function p4custom(f, x)
    c = StaticPolynomials.coefficients(f)
    @inbounds out = begin
       c1103 = @evalpoly(x[2], x[1], 1)
       c1107 = @evalpoly(x[2], x[1], 1)
       c1104 = @evalpoly(x[3], x[1] * x[2], c1103)
       c1109 = @evalpoly(x[3], c1107, 1)
       @evalpoly x[4] c1104 c1109
   end
   out
end

@btime p4custom($p4_f2, $r_4)

k

f2(big.(r_4))


f4(r_4) - StaticPolynomials._inline_evaluate(P4.f3, r_4)


StaticPolynomials.evaluate_impl(typeof(P4.f2))
