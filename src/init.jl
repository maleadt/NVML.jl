# Initialization and Cleanup

"""
Initialize the CUDA driver API.

This function is automatically called upon loading the package. You should not have to call
this manually.
"""
function init()
    # NOTE: this is a leap of faith, as there's both nvmlInit and nvmlInit_v2
    #       (and the version might have changed, but we can't query that before nvmlInit)
    @apicall(:nvmlInit, ())
end

shutdown() = @apicall(:nvmlShutdown, ())

function __init__()
    if !configured
        warn("NVML.jl has not been configured, and will not work properly.")
        warn("Please run Pkg.build(\"NVML\") and restart Julia.")
        return
    end

    init()

    if version() != libnvml_version
        error("NVML version has changed. Please re-run Pkg.build(\"NVML\") and restart Julia.")
    end
end
