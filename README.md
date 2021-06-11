# wea.jl

## What is wea?

Giving the package a meaning - wea stands for Wrapped Exchange Array. If you want to share array-packed data with different processes, remote nodes or different language executables ( yes, that's the vision ), wea is aiming to be a lean, lightweight and convenient alternative to [Protocol Buffers](https://developers.google.com/protocol-buffers) and Co.

It's inspired and adopted from Julia’s [InterProcessCommunication](https://github.com/emmt/InterProcessCommunication.jl) WrappedArray in collaboration with @emmt.

If this sounds good to you, just give it a try.

## Getting started

Install the package directly via

```julia
pkg> add https://github.com/casabre/wea.jl
```

until it is going to be registered.

## Quick API guide

If you want to use a plain `WrappedExchangeArray`, just try

```julia
using wea

id = "/shm-id";
T = Float64;
dims = (10, 2);

wa = WrappedExchangeArray(id, T, dims);
wa[:] = ones(T, dims);
```

in order to create a shared memory segment.

### Convenience functions

You can store any memory element within the Wrapped Exchange arrays. In order to reduce the setup hustle, you can utilize the following convenience modules.

#### Shared Exchange Array

In order to create a new shared memory segment, use the following snippet

```julia
using wea

key = "/shm-id";
T = Float64;
dims = (10, 2);

A = wea.SharedExchangeArray.create(key, T, dims)
A[:] = ones(T, dims)
id = wea.shmid(A)
B = wea.SharedExchangeArray.load(id; readonly=true)
```

#### Buffered Exchange Array

In order to share byte data via your favorite exchange protocol, you can use the following snippet.

```julia
using wea

T = Float32
dims = (3, 4, 5)
A = wea.BufferedExchangeArray.create(T, dims)
A[:] = ones(T, dims)
buf = wea.BufferedExchangeArray.get_exchange_buffer(A)
B = wea.BufferedExchangeArray.load(buf)
```

## Contributing

I welcome any contributions, enhancements, and bug-fixes.  [Open an issue](https://github.com/casabre/wea.jl/issues) on GitHub and [submit a pull request](https://github.com/casabre/wea.jl/pulls).

## License

wea.py is 100% free and open-source, under the [MIT license](LICENSE). Use it however you want.

This package is [Treeware](http://treeware.earth). If you use it in production, then we ask that you [**buy the world a tree**](https://plant.treeware.earth/casabre/wea.jl) to thank us for our work. By contributing to the Treeware forest you’ll be creating employment for local families and restoring wildlife habitats.
