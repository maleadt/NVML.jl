# queries and commands against the local system (ie. not device specific)

# TODO:
# - nvmlSystemGetProcessName

"""
Query the NVML version number.
"""
function version()
    buf = Vector{UInt8}(80)
    @apicall(:nvmlSystemGetNVMLVersion, (Ptr{UInt8}, Cuint), buf, length(buf))
    return VersionNumber(unsafe_string(pointer(buf)))
end

"""
Query the driver version number.
"""
function driver()
    buf = Vector{UInt8}(80)
    @apicall(:nvmlSystemGetDriverVersion, (Ptr{UInt8}, Cuint), buf, length(buf))
    return VersionNumber(unsafe_string(pointer(buf)))
end
