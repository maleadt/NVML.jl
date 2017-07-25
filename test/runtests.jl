using NVML
using Base.Test

using Compat

@testset "NVML" begin

include("util.jl")

include("base.jl")

if NVML.configured
    include("errors.jl")
    include("system.jl")
else
    warn("NVML.jl has not been configured; skipping most tests.")
end

end
