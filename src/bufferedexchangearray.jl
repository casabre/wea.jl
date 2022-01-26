module BufferedExchangeArray

export create, load, get_exchange_buffer

using wea:
    WrappedExchangeArray,
    WrappedArrayHeader,
    _wrapped_array_header_size

using InterProcessCommunication

function create(
    ::Type{T}, dims::Vararg{Integer,N}
)::WrappedExchangeArray where {T,N}
    return create(T, convert(NTuple{N,Int}, dims))
end

function create(
    ::Type{T}, dims::NTuple{N,Integer}
)::WrappedExchangeArray where {T,N}
    num = InterProcessCommunication.checkdims(dims)
    off = _wrapped_array_header_size(N)
    siz = off + sizeof(T) * num
    mem = zeros(UInt8, siz)
    write(mem, WrappedArrayHeader, T, dims)
    return WrappedExchangeArray(mem, T, dims; offset=off)
end

function load(mem::Vector{UInt8})::WrappedExchangeArray
    T, dims, off = read(mem, WrappedArrayHeader)
    return WrappedExchangeArray(mem, T, dims; offset=off)
end

function get_exchange_buffer(wea::WrappedExchangeArray)::Vector{UInt8}
    isa(wea.mem, Vector{UInt8}) ||
        InterProcessCommunication.throw_argument_error(
            "Data type not supported as exchange buffer"
        )
    return wea.mem
end

end # BufferedExchangeArray