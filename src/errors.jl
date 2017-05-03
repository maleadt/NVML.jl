# Error type and decoding functionality

export NVMLError


#
# API requirements errors
#

immutable NVMLVersionError <: Exception
    symbol::Symbol
    minver::VersionNumber
end

function Base.showerror(io::IO, err::NVMLVersionError)
    @printf(io, "NVMLVersionError: call to %s requires at least driver v%s",
            err.symbol, err.minver)
end


#
# Runtime API errors
#

immutable NVMLError <: Exception
    code::Int
    info::Nullable{String}

    NVMLError(code) = new(code, Nullable{String}())
    NVMLError(code, info) = new(code, Nullable{String}(info))
end

Base.:(==)(x::NVMLError,y::NVMLError) = x.code == y.code

const return_codes = Dict{Int,Tuple{Symbol,String}}(
    0   => (:SUCCESS,                       "The operation was successful"),

    1   => (:ERROR_UNINITIALIZED,           "NVML was not first initialized with nvmlInit()"),
    2   => (:ERROR_INVALID_ARGUMENT,        "A supplied argument is invalid"),
    3   => (:ERROR_NOT_SUPPORTED,           "The requested operation is not available on target device"),
    4   => (:ERROR_NO_PERMISSION,           "The current user does not have permission for operation"),
    5   => (:ERROR_ALREADY_INITIALIZED,     "Deprecated: Multiple initializations are now allowed through ref counting"),
    6   => (:ERROR_NOT_FOUND,               "A query to find an object was unsuccessful"),
    7   => (:ERROR_INSUFFICIENT_SIZE,       "An input argument is not large enough"),
    8   => (:ERROR_INSUFFICIENT_POWER,      "A device's external power cables are not properly attached"),
    9   => (:ERROR_DRIVER_NOT_LOADED,       "NVIDIA driver is not loaded"),
    10  => (:ERROR_TIMEOUT,                 "User provided timeout passed"),
    11  => (:ERROR_IRQ_ISSUE,               "NVIDIA Kernel detected an interrupt issue with a GPU"),
    12  => (:ERROR_LIBRARY_NOT_FOUND,       "NVML Shared Library couldn't be found or loaded"),
    13  => (:ERROR_FUNCTION_NOT_FOUND,      "Local version of NVML doesn't implement this function"),
    14  => (:ERROR_CORRUPTED_INFOROM,       "infoROM is corrupted"),
    15  => (:ERROR_GPU_IS_LOST,             "The GPU has fallen off the bus or has otherwise become inaccessible"),
    16  => (:ERROR_RESET_REQUIRED,          "The GPU requires a reset before it can be used again"),
    17  => (:ERROR_OPERATING_SYSTEM,        "The GPU control device has been blocked by the operating system/cgroups"),
    18  => (:ERROR_LIB_RM_VERSION_MISMATCH, "RM detects a driver/library version mismatch"),
    19  => (:ERROR_IN_USE,                  "An operation cannot be performed because the GPU is currently in use"),
    20  => (:ERROR_NO_DATA,                 "No data"),

    999 => (:ERROR_UNKNOWN,                 "An internal driver error occurred")
)

name(err::NVMLError)        = return_codes[err.code][1]
description(err::NVMLError) = return_codes[err.code][2]

function Base.showerror(io::IO, err::NVMLError)
    if isnull(err.info)
        @printf(io, "%s (NVML error #%d, %s)",
                    description(err), err.code, name(err))
    else
        @printf(io, "%s (NVML error #%d, %s)\n%s",
                    description(err), err.code, name(err), get(err.info))
    end
end

Base.show(io::IO, err::NVMLError) =
    @printf(io, "%s(%d)", name(err), err.code)

for code in return_codes
    @eval const $(code[2][1]) = NVMLError($(code[1]))
end
