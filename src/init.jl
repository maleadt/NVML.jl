# Initialization and Cleanup

"""
Initialize the NVML API.

This function is automatically called upon loading the package. You should not have to call
this manually.
"""
init() = @apicall(:nvmlInit, ())

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
