@testset "errors" begin

let
    ex = NVMLError(0)
    @test NVML.name(ex) == :SUCCESS
    @test NVML.description(ex) == "The operation was successful"
    
    io = IOBuffer()
    showerror(io, ex)
    str = String(take!(io))

    @test contains(str, "0")
    @test contains(str, "The operation was successful")
end

let
    ex = NVMLError(0, "foobar")
    
    io = IOBuffer()
    showerror(io, ex)
    str = String(take!(io))

    @test contains(str, "foobar")
end

end
