@testset "base" begin

for i in 1:4
    fun = Symbol(:nvmlDummyUnavailable, i)
    @test_throws NVML.NVMLVersionError NVML.resolve(fun)
end

for i in 1:2
    fun = Symbol(:nvmlDummyAvailable, i)
    NVML.resolve(fun)
end

@test_throws ErrorException eval(
    quote
        foo = :bar
        NVML.@apicall(foo, ())
    end
)

@test_throws_nvmlerror NVML.ERROR_INVALID_ARGUMENT NVML.@apicall(:nvmlUnitGetHandleByIndex, (Cuint, Ptr{Void}), 0, C_NULL)

NVML.version()
NVML.driver()

end
