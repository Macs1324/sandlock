{
  description = "Wayland screen locker: the desktop dissolves into a storm of its own pixels";

  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    lib = nixpkgs.lib;
    forAllSystems = f: lib.genAttrs ["x86_64-linux" "aarch64-linux"] (system: f nixpkgs.legacyPackages.${system});
  in {
    packages = forAllSystems (pkgs: rec {
      sandlock = pkgs.callPackage ./package.nix {};
      default = sandlock;
    });

    overlays.default = final: _: {
      sandlock = final.callPackage ./package.nix {};
    };

    # `nix develop` for iterating on the lock screen with cargo.
    devShells = forAllSystems (pkgs: {
      default = pkgs.mkShell {
        inputsFrom = [self.packages.${pkgs.stdenv.hostPlatform.system}.sandlock];
        packages = with pkgs; [cargo rustc clippy rustfmt rust-analyzer];
        LD_LIBRARY_PATH = lib.makeLibraryPath (with pkgs; [vulkan-loader libGL wayland libxkbcommon]);
        # Lets `cargo test` run the PAM conversation test (skipped without it).
        SANDLOCK_TEST_PAM_LIB = "${pkgs.linux-pam}/lib/security";
      };
    });

    formatter = forAllSystems (pkgs: pkgs.alejandra);
  };
}
