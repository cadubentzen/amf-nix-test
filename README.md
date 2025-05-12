# AMF test

This sample repo uses Nix to run a sample AMF application under GDB and reproduce crash from https://github.com/GPUOpen-LibrariesAndSDKs/AMF/issues/457#issuecomment-2443017454 and Mesa 25.0.5.

The crash is fixed by upgrading from AMF 1.4.34 to 1.4.36.

To reproduce the crash, switch the versions by replacing the commented lines in `./nix/packages.nix`.

Then, remember to have [nix flakes activated](https://nixos.wiki/wiki/Flakes) and run `nix run`. It will start a GDB console which you can `r` to get the crash. Bumping to 1.4.36 the crash is gone.
