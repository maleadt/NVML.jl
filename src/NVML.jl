__precompile__()

module NVML

using Compat
using Compat.String

const ext = joinpath(dirname(@__DIR__), "deps", "ext.jl")
if isfile(ext)
    include(ext)
else
    error("Unable to load dependency file $ext.\nPlease run Pkg.build(\"NVML\") and restart Julia.")
end
const libnvml = libnvml_path

include("errors.jl")
include("base.jl")

include("system.jl")
include("unit.jl")
include("device.jl")
include("event.jl")

function __init__()
    # NOTE: this is a leap of faith, as there's both nvmlInit and nvmlInit_v2
    #       (and the version might have changed, but we can't query that before nvmlInit)
    @apicall(:nvmlInit, (Cint,), 0)

    if version() != libnvml_version
        error("NVML version has changed. Please re-run Pkg.build(\"NVML\") and restart Julia.")
    end
end

end
