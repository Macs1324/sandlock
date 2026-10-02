# sandlock

A Wayland screen locker: the desktop dissolves into a storm of its own pixels,
and images, a clock or a Game of Life emerge from the sand.

Needs a compositor with `ext-session-lock-v1` and `wlr-screencopy-v1` (niri,
Hyprland, Sway, …) and a GPU that wgpu can drive (Vulkan or GL).

## Nix

```nix
# flake.nix
inputs.sandlock = {
  url = "github:Macs1324/sandlock";
  inputs.nixpkgs.follows = "nixpkgs";
};

# NixOS: the package, and the PAM service it authenticates against.
environment.systemPackages = [inputs.sandlock.packages.${pkgs.stdenv.hostPlatform.system}.default];
security.pam.services.sandlock = {};
```

`overlays.default` adds `pkgs.sandlock` instead. `nix develop` gives a shell
for working on it with cargo.

## Usage

```
sandlock              lock the session
sandlock -f           fork once the session is locked (for before-sleep hooks)
sandlock --preview    show the storm on a layer-shell surface, without locking
sandlock --config P   read P instead of ~/.config/sandlock/config.toml
```

Every key in `config.toml` is optional; see [`src/config.rs`](src/config.rs).

```toml
[storm]
intensity = 0.5

[[attractor]]
clock = {}
color = "#89b4fa"
position = [0.5, 0.64]
scale = 2.4
```

## License

MIT
