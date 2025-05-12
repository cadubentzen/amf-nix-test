{
    description = "A simple Nix flake for testing AMF";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        flake-utils.url = "github:numtide/flake-utils";
        nixgl = {
            url = "github:nix-community/nixGL";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = { self, nixpkgs, flake-utils, nixgl }:
        flake-utils.lib.eachDefaultSystem (system:
            let
                pkgs = import nixpkgs {
                    inherit system;
                    config = {
                        allowUnfree = true;
                    };
                    overlays = [ nixgl.overlay ];
                };

                localPackages = import ./nix/packages.nix {
                    inherit pkgs;
                };

                myPackage = pkgs.stdenv.mkDerivation {
                    pname = "amf-test";
                    version = "0.0.1";
                    src = ./.;

                    nativeBuildInputs = with pkgs; [
                        meson
                        ninja
                        pkg-config
                        localPackages.amf-headers
                    ];

                    buildInputs = with pkgs; [
                        localPackages.amdenc
                        localPackages.amf

                        mesa

                        vulkan-loader
                        vulkan-headers
                        vulkan-tools
                        vulkan-validation-layers

                        gdb
                    ];
                };

                libraryPath = pkgs.lib.makeLibraryPath [
                    localPackages.amf
                    localPackages.amdenc
                    pkgs.vulkan-loader
                ];

                runScript = pkgs.writeShellScript "run-amf-test" ''
                    #!${pkgs.runtimeShell}
                    export LD_LIBRARY_PATH=${libraryPath}
                    exec ${pkgs.nixgl.nixVulkanIntel}/bin/nixVulkanIntel gdb ${self.packages.${system}.default}/bin/amf-test
                    # exec ${pkgs.nixgl.nixVulkanIntel}/bin/nixVulkanIntel vulkaninfo
                '';
            in
            {
                packages.default = myPackage;

                apps.default = {
                    type = "app";
                    program = "${runScript}";
                };

                devShell = pkgs.mkShell {
                    inputsFrom = [ myPackage ];
                    LD_LIBRARY_PATH = libraryPath;
                };
            }
        );
}
