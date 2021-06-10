#
# wrappedarrays.jl --
#
# Management of object wrapped into Julia arrays.
#
#------------------------------------------------------------------------------
#
# This file is part of InterProcessCommunication.jl released under the MIT
# "expat" license.
#
# Copyright (C) 2016-2019, Éric Thiébaut
# (https://github.com/emmt/InterProcessCommunication.jl).
#

function WrappedExchangeArray(
    id::Union{AbstractString,ShmId,InterProcessCommunication.Key},
    ::Type{T},
    dims::Vararg{Integer,N};
    kwds...,
) where {T,N}
    return WrappedExchangeArray(
        id, T, convert(NTuple{N,Int}, dims); kwds...
    )
end

function WrappedExchangeArray(
    id::Union{AbstractString,ShmId,InterProcessCommunication.Key},
    ::Type{T},
    dims::NTuple{N,Integer};
    kwds...,
) where {T,N}
    return WrappedExchangeArray(
        id, T, convert(NTuple{N,Int}, dims); kwds...
    )
end

function WrappedExchangeArray(
    id::Union{AbstractString,ShmId,InterProcessCommunication.Key},
    ::Type{T},
    dims::NTuple{N,Int};
    kwds...,
) where {T,N}
    num = InterProcessCommunication.checkdims(dims)
    off = _wrapped_array_header_size(N)
    siz = off + sizeof(T) * num
    mem = SharedMemory(id, siz; kwds...)
    write(mem, WrappedArrayHeader, T, dims)
    return WrappedExchangeArray(mem, T, dims; offset=off)
end

function WrappedExchangeArray(
    id::Union{AbstractString,ShmId,InterProcessCommunication.Key};
    kwds...,
)
    mem = SharedMemory(id; kwds...)
    T, dims, off = read(mem, WrappedArrayHeader)
    return WrappedExchangeArray(mem, T, dims; offset=off)
end

function shmid(
    arr::WrappedExchangeArray{T,N,<:SharedMemory}
) where {T,N}
    return InterProcessCommunication.shmid(arr.mem)
end

module SharedExchangeArray

export create, load

using wea: WrappedExchangeArray

using InterProcessCommunication

function create(
    id::Union{AbstractString,ShmId,InterProcessCommunication.Key},
    ::Type{T},
    dims::Vararg{Integer,N};
    kwds...,
) where {T,N}
    return create(id, T, convert(NTuple{N,Int}, dims); kwds...)
end

function create(
    id::Union{AbstractString,ShmId,InterProcessCommunication.Key},
    ::Type{T},
    dims::NTuple{N,Int};
    kwds...,
)::WrappedExchangeArray where {T,N}
    return WrappedExchangeArray(id, T, dims; kwds...)
end

function load(
    id::Union{AbstractString,ShmId,InterProcessCommunication.Key};
    kwds...,
)::WrappedExchangeArray
    return WrappedExchangeArray(id; kwds...)
end

end # module SharedExchangeArray