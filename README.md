# wea.jl

## What is wea?

Giving the acronym a meaning - wea stands for Wrapped Exchange Array. If you want to share array-packed data with different processes, remote nodes or different language executables ( yes, that's the vision ), wea is aiming to be a lean, lightweight and convenient alternative to [Protocol Buffers](https://developers.google.com/protocol-buffers) and Co.

It's inspired and adopted partly from Julia’s [InterProcessCommunication](https://github.com/emmt/InterProcessCommunication.jl) WrappedArray.

If this sounds good to you, just give it a try.

## Status

wea.jl is currently under clarification and development. If you want to check how wea works, please check the [Python implementation](https://github.com/casabre/wea.py).

### Yes, that is cool and I want to use it now

Due to the fact that it is adopted from [InterProcessCommunication](https://github.com/emmt/InterProcessCommunication.jl), you can use the WrappedArray's of that package - for more details, please check [WrappedArrays](https://emmt.github.io/InterProcessCommunication.jl/dev/reference/#Wrapped-arrays-1).

```julia
using InterProcessCommunication;

id = "/shm-id";
T = Float64;
dims = (10, 2);

wa = WrappedArray(id, T, dims);
```

## Contributing

I welcome any contributions, enhancements, and bug-fixes.  [Open an issue](https://github.com/casabre/wea.jl/issues) on GitHub and [submit a pull request](https://github.com/casabre/wea.jl/pulls).

## License

wea.py is 100% free and open-source, under the [MIT license](LICENSE). Use it however you want.

This package is [Treeware](http://treeware.earth). If you use it in production, then we ask that you [**buy the world a tree**](https://plant.treeware.earth/casabre/wea.jl) to thank us for our work. By contributing to the Treeware forest you’ll be creating employment for local families and restoring wildlife habitats.
