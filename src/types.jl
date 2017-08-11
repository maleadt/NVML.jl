# Forward declarations of types

## from errors.jl

const nvmlReturn_t = Cint

immutable NVMLError <: Exception
    code::nvmlReturn_t
    meta::Any

    NVMLError(code, meta=nothing) = new(code, meta)
end
