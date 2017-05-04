using NVML
using Base.Test

using Compat

include("util.jl")

@testset "NVML" begin

include("errors.jl")
include("base.jl")

end