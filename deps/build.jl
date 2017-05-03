using Compat


## API routines

# these routines are the bare minimum we need from the API during build;
# keep in sync with the actual implementations in src/

macro apicall(libpath, fn, types, args...)
    quote
        lib = Libdl.dlopen($(esc(libpath)))
        sym = Libdl.dlsym(lib, $(esc(fn)))

        status = ccall(sym, Cint, $(esc(types)), $(map(esc, args)...))
        status != 0 && error("Error $status calling ", $fn)
    end
end

function init(libpath)
    @apicall(libpath, :nvmlInit, ())
    return
end

function shutdown(libpath)
    @apicall(libpath, :nvmlShutdown, ())
    return
end

function version(libpath)
    buf = Vector{UInt8}(128)
    @apicall(libpath, :nvmlSystemGetNVMLVersion, (Ptr{UInt8}, Cuint), buf, length(buf))
    return VersionNumber(unsafe_string(pointer(buf)))
end


## discovery routines

# find NVIDIA Management Library
function find_libnvml()
    libnvml_dir = is_windows() ? joinpath(ENV["ProgramFiles"], "NVIDIA Corporation", "NVSMI") : ""
    if is_windows() && !isdir(libnvml_dir)
        error("Could not determine NVIDIA driver installation location.")
    end
    # NOTE: no need to look in /opt/cuda or /usr/local/cuda here,
    #       as the driver is kernel-specific and should be installed in standard directories
    libnvml = Libdl.find_library(["libnvidia-ml", "nvml"], [libnvml_dir])
    isempty(libnvml) && error("NVIDIA Management Library cannot be found.")

    # find the full path of the library
    # NOTE: we could just as well use the result of `find_library,
    #       but the user might have run this script with eg. LD_LIBRARY_PATH set
    #       so we save the full path in order to always be able to load the correct library
    libnvml_path = Libdl.dlpath(libnvml)

    return libnvml_path
end


## main

const ext = joinpath(@__DIR__, "ext.jl")

function main()
    # discover stuff
    libnvml_path = find_libnvml()
    init(libnvml_path)
    libnvml_version = version(libnvml_path)
    shutdown(libnvml_path)

    # check if we need to rebuild
    if isfile(ext)
        @eval module Previous; include($ext); end
        if isdefined(Previous, :libnvml_version) && Previous.libnvml_version == libnvml_version &&
           isdefined(Previous, :libnvml_path)    && Previous.libnvml_path == libnvml_path
            info("NVML.jl has already been built for this set-up.")
        end
    end

    # write ext.jl
    open(ext, "w") do fh
        write(fh, """
            const libnvml_path = "$(escape_string(libnvml_path))"
            const libnvml_version = v"$libnvml_version"
            """)
    end
    nothing
end

try
    main()
catch ex
    # if anything goes wrong, wipe the existing ext.jl to prevent the package from loading
    rm(ext; force=true)
    rethrow(ex)
end
