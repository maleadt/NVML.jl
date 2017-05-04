# variant on @test_throws that checks the NVMLError error code
macro test_throws_nvmlerror(kind, ex)
    # generate a test only returning NVMLError if it is the correct one
    test = quote
        try
            $(esc(ex))
        catch ex
            isa(ex, NVMLError) || rethrow()
            ex == $kind        || rethrow(ErrorException(string("Wrong NVMLError kind: ", ex, " instead of ", $kind)))
            rethrow()
        end
    end

    # now re-use @test_throws (which ties into @testset, etc)
    quote
        @test_throws NVMLError $test
    end
end

mutable struct NoThrowTestSet <: Base.Test.AbstractTestSet
    results::Vector
    NoThrowTestSet(desc) = new([])
end
Base.Test.record(ts::NoThrowTestSet, t::Base.Test.Result) = (push!(ts.results, t); t)
Base.Test.finish(ts::NoThrowTestSet) = ts.results
fails = @testset NoThrowTestSet begin
    # OK
    @test_throws_nvmlerror NVML.ERROR_UNKNOWN throw(NVML.ERROR_UNKNOWN)
    # Fail, wrong NVMLError
    @test_throws_nvmlerror NVML.ERROR_UNKNOWN throw(NVML.ERROR_INVALID_VALUE)
    # Fail, wrong Exception
    @test_throws_nvmlerror NVML.ERROR_UNKNOWN error()
end
@test isa(fails[1], Base.Test.Pass)
@test isa(fails[2], Base.Test.Fail)
@test isa(fails[3], Base.Test.Fail)
