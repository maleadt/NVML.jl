@testset "base" begin

@test_throws ErrorException NVML.@apicall(:nvmlNonexisting, ())

@test_throws ErrorException @eval NVML.@apicall(:nvmlDummyAvailable, ())
@test_throws NVML.NVMLVersionError @eval NVML.@apicall(:nvmlDummyUnavailable, ())

@test_throws ErrorException eval(
    quote
        foo = :bar
        NVML.@apicall(foo, ())
    end
)

@test_throws_nvmlerror NVML.ERROR_INVALID_ARGUMENT NVML.@apicall(:nvmlUnitGetHandleByIndex, (Cuint, Ptr{Void}), 0, C_NULL)

end
