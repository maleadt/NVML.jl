# Error type and decoding functionality

export NVMLError


#
# Versioning error
#

immutable NVMLVersionError <: Exception
    symbol::Symbol
    minver::Nullable{VersionNumber}
    maxver::Nullable{VersionNumber}
end

function Base.showerror(io::IO, err::NVMLVersionError)
    print(io, "NVMLVersionError: API function $(err.symbol) is only available ")
    if isnull(err.minver)
        println(io, "below driver $(get(err.maxver))")
    elseif isnull(err.maxver)
        println(io, "starting with driver $(get(err.minver))")
    else
        println(io, "between driver $(get(err.minver)) and $(get(err.maxver))")
    end
end


#
# API errors
#

# immutable NVMLError <: Exception

Base.:(==)(x::NVMLError,y::NVMLError) = x.code == y.code

name(err::NVMLError) = return_codes[err.code]

function description(err::NVMLError)
    str_ref = @unsafe_apicall(:nvmlErrorString, Cstring, (nvmlReturn_t,), err.code)
    unsafe_string(str_ref)
end

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

# known error constants
const return_codes = Dict{nvmlReturn_t,Symbol}(
    0   => :SUCCESS,

    1   => :ERROR_UNINITIALIZED,
    2   => :ERROR_INVALID_ARGUMENT,
    3   => :ERROR_NOT_SUPPORTED,
    4   => :ERROR_NO_PERMISSION,
    5   => :ERROR_ALREADY_INITIALIZED,
    6   => :ERROR_NOT_FOUND,
    7   => :ERROR_INSUFFICIENT_SIZE,
    8   => :ERROR_INSUFFICIENT_POWER,
    9   => :ERROR_DRIVER_NOT_LOADED,
    10  => :ERROR_TIMEOUT,
    11  => :ERROR_IRQ_ISSUE,
    12  => :ERROR_LIBRARY_NOT_FOUND,
    13  => :ERROR_FUNCTION_NOT_FOUND,
    14  => :ERROR_CORRUPTED_INFOROM,
    15  => :ERROR_GPU_IS_LOST,
    16  => :ERROR_RESET_REQUIRED,
    17  => :ERROR_OPERATING_SYSTEM,
    18  => :ERROR_LIB_RM_VERSION_MISMATCH,
    19  => :ERROR_IN_USE,
    20  => :ERROR_NO_DATA,

    999 => :ERROR_UNKNOWN
)
for code in return_codes
    @eval const $(code[2]) = NVMLError($(code[1]))
end
