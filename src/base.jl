# Basic library functionality

#
# API versioning
#

const mapping = Dict{Symbol,Symbol}()
const minreq = Dict{Symbol,VersionNumber}()

# NOTE: nvmlDeviceGetPciInfo_v2 and nvmlDeviceGetHandleByPciBusId_v2 are not explicitly
# mentioned to be introduced in 5.319, but it seems plausible given that's when other v2
# methods started appearing in the API
if libnvml_version >= v"5.319"
    mapping[:nvmlInit]                      = :nvmlInit_v2
    mapping[:nvmlDeviceGetCount]            = :nvmlDeviceGetCount_v2
    mapping[:nvmlDeviceGetPciInfo]          = :nvmlDeviceGetPciInfo_v2
    mapping[:nvmlDeviceGetHandleByIndex]    = :nvmlDeviceGetHandleByIndex_v2
    mapping[:nvmlDeviceGetHandleByPciBusId] = :nvmlDeviceGetHandleByPciBusId_v2
end


## Version-dependent features

# none yet?

minreq[:nvmlDummyAvailable]   = v"0"      # non-existing functions
minreq[:nvmlDummyUnavailable] = v"999"    # for testing purposes

# explicitly mark unavailable symbols, signaling `resolve` to error out
for (api_function, minimum_version) in minreq
    if libnvml_version < minimum_version
        mapping[api_function]      = Symbol()
    end
end

function resolve(f::Symbol)
    global mapping, version_requirements
    versioned_f = get(mapping, f, f)
    if versioned_f == Symbol()
        throw(CuVersionError(f, minreq[f]))
    end
    return versioned_f
end


#
# API call wrapper
#

# ccall wrapper for calling functions in the CUDA library
macro apicall(f, argtypes, args...)
    # Escape the tuple of arguments, making sure it is evaluated in caller scope
    # (there doesn't seem to be inline syntax like `$(esc(argtypes))` for this)
    esc_args = [esc(arg) for arg in args]

    blk = Expr(:block)

    if !isa(f, Expr) || f.head != :quote
        error("first argument to @apicall should be a symbol")
    end

    # Generate the actual call
    api_f = resolve(f.args[1])
    @gensym status
    push!(blk.args, quote
        $status = ccall(($(QuoteNode(api_f)), libnvml), Cint, $(esc(argtypes)), $(esc_args...))
    end)

    # Check the return code
    push!(blk.args, quote
        if $status != SUCCESS.code
            err = CuError($status)
            throw(err)
        end
    end)

    return blk
end


#
# Basic functionality
#

"""
Returns the NVML version as a VersionNumber.
"""
function version()
    buf = Vector{UInt8}(128)
    @apicall(:nvmlSystemGetNVMLVersion, (Ptr{UInt8}, Cuint), buf, length(buf))
    return VersionNumber(unsafe_string(pointer(buf)))
end
