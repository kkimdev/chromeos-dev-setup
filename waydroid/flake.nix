{
  description = "Linux kernel development environment using latest LLVM";

  inputs = {
    # Using nixos-unstable to get the most recent LLVM releases
    nixpkgs.url = "github:Nixos/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        # This alias always points to the highest stable LLVM version in nixpkgs
        llvm = pkgs.llvmPackages_latest;
      in
      {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            # Build Essentials
#            gnumake
#            binutils
#            flex
#            bison
#            bc
#            elfutils
            git

            # Latest LLVM Toolchain
            llvm.clang
            llvm.lld
            llvm.llvm
            llvm.bintools # Provides llvm-ar, llvm-nm, llvm-objcopy, etc.
          ];

          shellHook = ''
            echo "--- Latest LLVM Environment Loaded ---"
            echo "Clang: $(clang --version | head -n 1)"
            
            # Kernel build overrides
            export CC=clang
            export LD=ld.lld
            export AR=llvm-ar
            export NM=llvm-nm
            export STRIP=llvm-strip
            export OBJCOPY=llvm-objcopy
            export OBJDUMP=llvm-objdump
            export READELF=llvm-readelf
            export HOSTCC=clang
          '';
        };
      });
}
