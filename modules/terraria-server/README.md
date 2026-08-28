# terraria-server

A NixOS module for running a vanilla Terraria dedicated server, wrapping
nixpkgs' `services.terraria`. Lives inside the shared
[nix-modules](../../) repo, exposed as `nixosModules.terraria-server`.

No mod support — vanilla Terraria has none. Mods require tModLoader (a
separate community mod-loader, not packaged in nixpkgs, and Workshop-based
mod fetching via `steamcmd`), which is a substantially different and
bigger build; this module intentionally doesn't attempt it.

## Quick start

```nix
# in your NixOS config's flake.nix
inputs.nix-modules = {
  url = "github:crbroughton/nix-modules";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

```nix
# modules/terraria-server.nix
{ inputs, ... }:
{
  imports = [ inputs.nix-modules.nixosModules.terraria-server ];
}
```

```nix
services.terraria-server = {
  enable = true;
  password = "...";
  messageOfTheDay = "Welcome!";
};
```

No credentials or `--impure` needed — the server binary is a public,
unauthenticated download (`terraria.org/api/download/...`), unlike
Factorio's mod downloads.

## Options reference (`services.terraria-server`)

- `enable` — turn the server on.
- `package` — Terraria server package to run (default `pkgs.terraria-server`).
- `openFirewall` — open `port` (TCP+UDP) in the firewall (default `true`).
- `port` — port to listen on (default `7777`).
- `maxPlayers` — max players, 1-255 (default `255`).
- `password` — server password (default `null`, no password). Plaintext CLI
  argument — visible in the Nix store and process list.
- `messageOfTheDay` — message shown to players on join.
- `worldPath` — path to a `.wld` world file to load. If missing, a new
  world is auto-created there at `autoCreatedWorldSize`.
- `autoCreatedWorldSize` — `"small"` / `"medium"` / `"large"` (default `"medium"`).
- `banListPath` — path to the ban list.
- `secure` — additional cheat protection (default `false`).
- `noUPnP` — disable automatic UPnP (default `false`).
- `dataDir` — state directory (default `/var/lib/terraria`).
- `difficulty` — `"classic"` / `"expert"` / `"master"` / `"journey"` (default
  `null`, server default of classic). Only applies when the world at
  `worldPath` is first created — no effect on an already-existing world file.
- `worldSeed` — seed for a newly-created world (default `null`, random).
  Accepts numeric seeds and Terraria's special string seeds (e.g.
  `"getfixedboi"`). Same caveat as `difficulty`: only applies at world
  creation.

## Admin console

The underlying `services.terraria` module runs the server inside `tmux`.
Attach for admin commands as a user in the `terraria` group:

```bash
tmux -S /var/lib/terraria/terraria.sock attach
```

`Ctrl-b d` to detach without stopping the server.
