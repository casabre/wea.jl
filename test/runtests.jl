using wea
using InterProcessCommunication
using ResumableFunctions
using Test

@resumable function ipc_keys()
    for key in
        (InterProcessCommunication.PRIVATE, "/wrsharr-$(getpid())")
        if isa(key, String)
            try
                shmrm(key)
            catch err
            end
        end
        @yield key
    end
end

@testset "wea.jl" begin
    @testset "Wrapped Exchange Array Tests" begin
        begin
            T = Float32
            dims = (5, 6)
            buf = DynamicMemory(sizeof(T) * prod(dims))
            A = WrappedExchangeArray(buf, T, dims)
            B = WrappedExchangeArray(buf) # indexable byte buffer
            C = WrappedExchangeArray(buf, T) # indexable byte buffer
            D = WrappedExchangeArray(buf, b -> (T, dims, 0)) # all parameters provided by a function
            A[:] = 1:length(A) # fill A before the copy
            E = copy(A)
            n = prod(dims)
            @test ndims(A) == ndims(D) == ndims(E) == length(dims)
            @test size(A) == size(D) == size(E) == dims
            @test all(
                size(A, i) == size(D, i) == dims[i] for
                i in 1:length(dims)
            )
            @test eltype(A) == eltype(C) == eltype(D) == T
            @test Base.elsize(A) == Base.sizeof(T)
            @test length(A) ==
                  length(C) ==
                  div(length(B), sizeof(T)) ==
                  length(D) ==
                  n
            @test sizeof(A) ==
                  sizeof(B) ==
                  sizeof(C) ==
                  sizeof(D) ==
                  sizeof(buf)
            @test pointer(A) ==
                  pointer(B) ==
                  pointer(C) ==
                  pointer(D) ==
                  pointer(buf)
            @test isa(A.arr, Array{T,length(dims)})
            @test A[1] == 1 && A[end] == prod(dims)
            @test all(A[i] == i for i in 1:n)
            @test all(C[i] == i for i in 1:n)
            @test all(D[i] == i for i in 1:n)
            @test all(E[i] == i for i in 1:n)
            B[:] .= 0
            @test all(A[i] == 0 for i in 1:n)
            C[:] = randn(T, n)
            flag = true
            for i in eachindex(A, D)
                if A[i] != D[i]
                    flag = false
                end
            end
            @test flag
            B[:] .= 0
            A[2, 3] = 23
            A[3, 2] = 32
            @test D[2, 3] == 23 && D[3, 2] == 32
            # Test copy back.
            copyto!(A, E)
            @test all(A[i] == E[i] for i in 1:n)
        end
        GC.gc() # call garbage collector to exercise the finalizers
    end

    @testset "Shared Array Base Tests" begin
        begin
            T = Float32
            dims = (3, 4, 5)
            for key in ipc_keys()
                A = wea.WrappedExchangeArray(key, T, dims)
                id = wea.shmid(A)
                if isa(id, ShmId)
                    info = ShmInfo(id)
                    @test info.segsz ≥ sizeof(A) + 64
                end
                B = wea.WrappedExchangeArray(id; readonly=false)
                C = wea.WrappedExchangeArray(id; readonly=true)
                n = length(A)
                @test wea.shmid(A) ==
                      wea.shmid(B) ==
                      wea.shmid(C) ==
                      id
                @test sizeof(A) ==
                      sizeof(B) ==
                      sizeof(C) ==
                      n * sizeof(T)
                @test eltype(A) == eltype(B) == eltype(C) == T
                @test size(A) == size(B) == size(C) == dims
                @test length(A) ==
                      length(B) ==
                      length(C) ==
                      prod(dims)
                @test all(
                    size(A, i) == size(B, i) == size(C, i) == dims[i]
                    for i in 1:length(dims)
                )
                A[:] = 1:n
                @test first(A) == 1
                @test last(A) == n
                @test A[end] == n
                @test all(B[i] == i for i in 1:n)
                @test all(C[i] == i for i in 1:n)
                B[:] = -(1:n)
                @test extrema(A[:] + (1:n)) == (0, 0)
                @test all(C[i] == -i for i in 1:n)
                @test_throws ReadOnlyMemoryError C[end] = 42
                @test ccall(
                    :memset,
                    Ptr{Cvoid},
                    (Ptr{Cvoid}, Cint, Csize_t),
                    A,
                    0,
                    sizeof(A),
                ) == pointer(A)
                @test extrema(C) == (0, 0)
            end
        end
        GC.gc() # call garbage collector to exercise the finalizers
    end

    @testset "Shared Exchange Array Tests" begin
        begin
            T = Float32
            dims = (3, 4, 5)
            for key in ipc_keys()
                A = wea.SharedExchangeArray.create(key, T, dims)
                A[:] = ones(T, dims)
                id = wea.shmid(A)
                B = wea.SharedExchangeArray.load(id; readonly=true)
                @test A == B
            end
        end
        GC.gc() # call garbage collector to exercise the finalizers
    end

    @testset "Shared Exchange Array Tests" begin
        begin
            T = Float32
            dims = (3, 4, 5)
            A = wea.BufferedExchangeArray.create(T, dims)
            A[:] = ones(T, dims)
            buf = wea.BufferedExchangeArray.get_exchange_buffer(A)
            B = wea.BufferedExchangeArray.load(buf)
            @test A == B
        end
        GC.gc() # call garbage collector to exercise the finalizers
    end
end
