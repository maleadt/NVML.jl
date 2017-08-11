# Basic library functionality

#
# API versioning
#

# TODO: should we match against the NVML version, or the driver version?

const mapping = Dict{Symbol,Symbol}()

# NOTE: nvmlDeviceGetPciInfo_v2 and nvmlDeviceGetHandleByPciBusId_v2 are not explicitly
# mentioned to be introduced in 5.319, but it seems plausible given that's when other v2
# methods started appearing in the API
if driver_version >= v"319"
    mapping[:nvmlInit]                      = :nvmlInit_v2
    mapping[:nvmlDeviceGetCount]            = :nvmlDeviceGetCount_v2
    mapping[:nvmlDeviceGetPciInfo]          = :nvmlDeviceGetPciInfo_v2
    mapping[:nvmlDeviceGetHandleByIndex]    = :nvmlDeviceGetHandleByIndex_v2
    mapping[:nvmlDeviceGetHandleByPciBusId] = :nvmlDeviceGetHandleByPciBusId_v2
end


## Version-dependent features

const minver = Dict{Symbol,VersionNumber}()     # inclusive
const maxver = Dict{Symbol,VersionNumber}()     # exclusive

# changes between NVML v1.0 and v2.285
let ver = v"285"
    minver[:nvmlDeviceGetVbiosVersion] = ver
    minver[:nvmlErrorString] = ver
    minver[:nvmlSystemGetHicVersion] = ver
    minver[:nvmlDeviceGetMaxClockInfo] = ver
    minver[:nvmlDeviceGetComputeRunningProcesses] = ver
    minver[:nvmlSystemGetProcessName] = ver

    maxver[:nvmlDeviceGetPowerState] = ver # nvmlDeviceGetPerformanceState
end

# changes between NVML v2.285 and v3.295
let ver = v"295"
    minver[:nvmlDeviceGetMaxPcieLinkGeneration] = ver
    minver[:nvmlDeviceGetMaxPcieLinkWidth] = ver
    minver[:nvmlDeviceGetCurrPcieLinkGeneration] = ver
    minver[:nvmlDeviceGetCurrPcieLinkWidth] = ver
    minver[:nvmlDeviceGetHandleByUUID] = ver

    maxver[:nvmlDeviceGetHandleBySerial] = ver # nvmlDeviceGetHandleByUUID
end

# changes between NVML v3.295 and v4.304 RC
let ver = v"304"
    minver[:nvmlDeviceGetInforomConfigurationChecksum] = ver
    minver[:nvmlDeviceValidateInforom] = ver
    minver[:nvmlDeviceGetDisplayActive] = ver
    minver[:nvmlDeviceSetApplicationsClocks] = ver
    minver[:nvmlDeviceGetApplicationsClock] = ver
    minver[:nvmlDeviceResetApplicationsClocks] = ver
    minver[:nvmlDeviceGetSupportedMemoryClocks] = ver
    minver[:nvmlDeviceGetSupportedGraphicsClocks] = ver
    minver[:nvmlDeviceGetPowerManagementLimitConstraints] = ver
    minver[:nvmlDeviceGetPowerManagementDefaultLimit] = ver
    minver[:nvmlDeviceSetPowerManagementLimit] = ver
    minver[:nvmlDeviceGetInforomImageVersion] = ver
    minver[:nvmlDeviceGetCurrentClocksThrottleReasons] = ver
    minver[:nvmlDeviceGetSupportedClocksThrottleReasons] = ver

    maxver[:nvmlDeviceGetDetailedEccErrors] = ver  # nvmlDeviceGetMemoryErrorCounter
end

# changes between NVML v4.304 RC and v4.304 Production
let ver = v"304"
    minver[:nvmlDeviceGetGpuOperationMode] = ver
    minver[:nvmlDeviceSetGpuOperationMode] = ver
end

# changes between NVML v4.304 Production and v5.319 RC
let ver = v"5.319"
    minver[:nvmlDeviceGetIndex] = ver
    minver[:nvmlDeviceGetAccountingStats] = ver
    minver[:nvmlDeviceGetRetiredPages] = ver
    minver[:nvmlDeviceGetRetiredPagesPendingStatus] = ver
    minver[:nvmlClocksThrottleReasonApplicationsClocksSetting] = ver
    minver[:nvmlDeviceGetDisplayActive] = ver

    maxver[:nvmlClocksThrottleReasonUserDefinedClocks] = ver # nvmlClocksThrottleReasonApplicationsClocksSetting
end

# changes between NVML v5.319 RC and v5.319 Update
let ver = v"319"
    minver[:nvmlDeviceSetAPIRestriction] = ver
    minver[:nvmlDeviceGetAPIRestriction] = ver
end

# changes between NVML v5.319 Update and v331
let ver = v"331"
    minver[:nvmlDeviceGetMinorNumber] = ver
    minver[:nvmlDeviceGetBAR1MemoryInfo] = ver
    minver[:nvmlDeviceGetBridgeChipInfo] = ver
    minver[:nvmlDeviceGetEnforcedPowerLimit] = ver
end

# changes between NVML v331 and v340
let ver = v"340"
    minver[:nvmlDeviceGetSamples] = ver
    minver[:nvmlDeviceGetTemperatureThreshold] = ver
    minver[:nvmlDeviceGetBrand] = ver
    minver[:nvmlDeviceGetViolationStatus] = ver
    minver[:nvmlDeviceGetEncoderUtilization] = ver
    minver[:nvmlDeviceGetDecoderUtilization] = ver
    minver[:nvmlDeviceGetCpuAffinity] = ver
    minver[:nvmlDeviceSetCpuAffinity] = ver
    minver[:nvmlDeviceClearCpuAffinity] = ver
    minver[:nvmlDeviceGetBoardId] = ver
    minver[:nvmlDeviceGetMultiGpuBoard] = ver
    minver[:nvmlDeviceGetAutoBoostedClocksEnabled] = ver
    minver[:nvmlDeviceSetAutoBoostedClocksEnabled] = ver
    minver[:nvmlDeviceSetDefaultAutoBoostedClocksEnabled] = ver
end

# changes between v340 and v346
let ver = v"346"
    minver[:nvmlDeviceGetGraphicsRunningProcesses] = ver
    minver[:nvmlDeviceGetPcieReplayCounter] = ver
    minver[:nvmlDeviceGetPcieThroughput] = ver
end

# changes between v346 and v349
let ver = v"349"
    minver[:nvmlDeviceGetTopologyCommonAncestor] = ver
    minver[:nvmlDeviceGetTopologyNearestGpus] = ver
    minver[:nvmlSystemGetTopologyGpuSet] = ver
end

# non-existing functions for testing purposes
minver[:nvmlDummyUnavailable1]   = v"999"
maxver[:nvmlDummyUnavailable2]   = v"0"
minver[:nvmlDummyUnavailable3]   = v"0"
maxver[:nvmlDummyUnavailable3]   = v"1"
maxver[:nvmlDummyUnavailable4]   = driver_version
minver[:nvmlDummyAvailable1]     = v"0"
maxver[:nvmlDummyAvailable1]     = v"999"
minver[:nvmlDummyAvailable2]     = driver_version

# explicitly mark unavailable symbols, signaling `resolve` to error out
const versioned_functions = keys(minver) ∪ keys(maxver)
for fun in versioned_functions
    minimum_version = get(minver, fun, v"0")    
    maximum_version = get(maxver, fun, v"999")

    if !(minimum_version <= driver_version < maximum_version)
        mapping[fun] = :unavailable
    end
end

function resolve(fun::Symbol)
    global mapping, version_requirements
    api_fun = get(mapping, fun, fun)
    if api_fun == :unavailable
        throw(NVMLVersionError(fun,
                               get(minver, fun, Nullable{VersionNumber}()),
                               get(maxver, fun, Nullable{VersionNumber}())))
    end
    return api_fun
end


#
# API call wrapper
#

# ccall wrapper for calling functions in NVIDIA libraries
macro unsafe_apicall(fun, rettyp, argtypes, args...)
    if !isa(fun, Expr) || fun.head != :quote
        error("first argument to @apicall should be a symbol")
    end

    api_fun = resolve(fun.args[1])  # TODO: make this error at runtime?

    configured || return :(error("NVML.jl has not been configured."))

    return quote
        ccall(($(QuoteNode(api_fun)), libnvml), $(esc(rettyp)),
                   $(esc(argtypes)), $(map(esc, args)...))
    end
end

# ccall wrapper for calling functions in NVIDIA libraries,
# checking the return code for validity
macro apicall(fun, argtypes, args...)
    return quote
        status = @unsafe_apicall($(esc(fun)), Cint,
                                 $(esc(argtypes)), $(map(esc, args)...))

        if status != SUCCESS.code
            err = NVMLError(status)
            throw(err)
        end
    end
end
