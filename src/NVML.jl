__precompile__()

module NVML

using Compat
using Compat.String

const ext = joinpath(dirname(@__DIR__), "deps", "ext.jl")
const configured = if isfile(ext)
    include(ext)
    true
else
    const driver_version = v"285"
    const libnvml_path = nothing
    false
end
const libnvml = libnvml_path

include("types.jl")
include("base.jl")

# NVML API wrappers
include("init.jl")
include("errors.jl")
include("system.jl")
include("unit.jl")
include("device.jl")
include("event.jl")
include("accounting.jl")

end
