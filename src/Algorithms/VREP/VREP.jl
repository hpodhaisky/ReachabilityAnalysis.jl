# TODO:
#
# Optionally apply convex hull
# Preallocations

"""
    VREP{N, AM, S, D} <: AbstractContinuousPost

Implementation a linear reachability solver for homogeneous systems using
vertex representation.
"""
struct VREP{N, AM, S, D} <: AbstractContinuousPost
    δ::N
    approx_model::AM
    static::S
    dim::D
end

# convenience constructor using symbols
function VREP(; δ::N,
                approx_model::AM=Forward(sih=:concrete, exp=:base, setops=:vrep),
                dim::Union{Int, Missing}=missing,
                static::Bool=!ismissing(dim)) where {N, AM}

    n = ismissing(dim) ? missing : Val(dim)
    return VREP(δ, approx_model, Val(static), n)
end

step_size(alg::VREP) = alg.δ
numtype(::VREP{N}) where {N} = N

function setrep(alg::VREP{N, AM, Val{false}, Missing}) where {N, AM}
    return VPolytope{N, Vector{N}}
end

function setrep(alg::VREP{N, AM, Val{false}, D}) where {N, AM, D}
    return VPolygon{N, Vector{N}}
end

function setrep(alg::VREP{N, AM, Val{true}, Missing}) where {N, AM}
    error("the set representation of this algorithm requires the dimension to be specified, but it is $(alg.dim)")
end

function setrep(alg::VREP{N, AM, Val{true}, Val{2}}) where {N, AM}
    return VPolygon{N, SVector{2, N}}
end

function setrep(alg::VREP{N, AM, Val{true}, Val{n}}) where {N, AM, n}
    return VPolytope{N, SVector{n, N}}
end

function rsetrep(alg::VREP{N}) where {N}
    ST = setrep(alg)
    RT = ReachSet{N, ST}
end

include("post.jl")
include("reach_homog.jl")
