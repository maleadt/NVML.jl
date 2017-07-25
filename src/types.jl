# Forward declarations of types

## from errors.jl

const nvmlReturn_t = Cint

immutable NVMLError <: Exception
    code::nvmlReturn_t
    info::Nullable{String}

    NVMLError(code) = new(code, Nullable{String}())
    NVMLError(code, info) = new(code, Nullable{String}(info))
end
