# factorio-server

A NixOS module for running a Factorio dedicated server, with a mod-toggle
system layered on top of nixpkgs' `services.factorio`. Lives inside the
shared [nix-modules](../../) repo, alongside the home-manager modules
(helix, zellij, neovim), and is exposed as
`nixosModules.factorio-server` from that repo's `flake.nix`.

## Files (this directory)

| File | Purpose |
| --- | --- |
| `default.nix` | The NixOS module. Defines `services.factorio-server`, a wrapper around `services.factorio` with a full option surface and a mod-toggle API. |
| `mods.nix` | The mod registry — one entry per installable mod (name, version, download path, hash). |
| `.env` / `.env.example` | `FACTORIO_USERNAME` / `FACTORIO_TOKEN` used to download mods from mods.factorio.com at build time. `.env` is gitignored (see this directory's `.gitignore`) — never commit it. |

## Quick start

Consume it through `nix-modules`' flake, not directly:

```nix
# in your NixOS config's flake.nix
inputs.nix-modules = {
  url = "github:crbroughton/nix-modules";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Then wire it into your module tree with a small wrapper (needed so
`inputs` is reachable from a plain module file):

```nix
# modules/factorio-server.nix
{ inputs, ... }:
{
  imports = [ inputs.nix-modules.nixosModules.factorio-server ];
}
```

And set `services.factorio-server` on the host:

```nix
services.factorio-server = {
  enable = true;
  admins = [ "yourname" ];
  mods = {
    enable = true;
    even-distribution = true;
  };
};
```

### Testing against a local, unpushed checkout

While iterating on this module before pushing `nix-modules` to GitHub,
point the input at the local checkout instead:

```nix
inputs.nix-modules.url = "path:/home/you/code/nix-modules";
```

**Two gotchas with this:**

1. `path:` inputs get content-hash-pinned in your config's `flake.lock` the
   first time they're used. Any time you edit files under `nix-modules`
   (including this module), your NixOS config won't see the change until
   you refresh that pin:

   ```bash
   nix flake update nix-modules --impure
   ```

   Skip this and a rebuild silently uses stale code.

2. `nix-modules` is a git checkout — flakes backed by git only read
   **tracked** files. New/edited files here need `git add`ing (staging is
   enough, no commit required) before the flake will see them at all:

   ```bash
   cd /home/you/code/nix-modules
   git add modules/factorio-server
   ```

Once you're happy with changes, commit and push `nix-modules` for real, and
switch the input back to `github:crbroughton/nix-modules` (`nix flake
update nix-modules --impure` again to pin the pushed commit).

### Mod downloads require `--impure`

Mod zips are fetched from mods.factorio.com at evaluation time using
credentials read from the environment (`FACTORIO_USERNAME`/`FACTORIO_TOKEN`),
via `builtins.getEnv`. That means:

```bash
cd modules/factorio-server   # this directory, wherever nix-modules lives
cp .env.example .env   # then fill in real values
set -a; source .env; set +a
sudo -E nixos-rebuild switch --flake /path/to/your-config#myhost --impure
```

Credentials are read from the environment specifically so they never end up
committed in `default.nix`. They **do** still end up in the Nix store,
though — the mod-download URL (with credentials in the query string) is a
fixed-output derivation input, and `.drv` files are world-readable on
multi-user systems. Fine for a personal/private host; if that's a concern,
switch to a private builder or a token you're willing to rotate.

If you're deploying via `sudo`, use `sudo -E` (not plain `sudo`) so the
sourced environment variables survive into the root shell that actually
evaluates the flake — otherwise `nixos-rebuild` runs unauthenticated and
every mod fetch 403s.

## Mod / Factorio-version compatibility

Factorio enforces that every mod's declared `factorio_version`
(major.minor only, e.g. `2.0` or `2.1`) matches the running server's
major.minor **exactly**. A single mismatched mod makes the whole server
refuse to start — not just that mod — which systemd then reports as a
crash loop (`start-limit-hit`) with the real reason buried in
`journalctl -u factorio.service`:

```
Error Util.cpp:81: Failed to load mod "<name>":
    • Incompatible Factorio version (current: 2.1, required: 2.0)
```

Practical implications:

- Every entry in `mods.nix` must be on a release matching whichever
  Factorio version `services.factorio-server` actually runs (see
  `package`/`build.version` below).
- Bumping `build.version` to a new Factorio minor version means **every**
  enabled mod needs to be re-checked/updated in lockstep — see the
  `/sync-factorio-mods` skill below.
- If a mod has no release for the target Factorio version yet, don't force
  it — disable it until the mod author catches up.

## Adding a mod

The `/add-factorio-mod` skill automates all of this given a download link —
the manual steps below are what it does under the hood.

1. Get its download link, e.g. from a URL like
   `https://mods.factorio.com/download/even-distribution/6717f7ef79bf4bb954bf7731`
   — the `downloadPath` is everything after `mods.factorio.com`
   (`/download/even-distribution/6717f7ef79bf4bb954bf7731`).
2. Compute the hash (requires your `.env` credentials, since the download
   needs auth):

   ```bash
   set -a; source .env; set +a
   HASH=$(nix-prefetch-url --type sha256 \
     "https://mods.factorio.com/download/<mod-name>/<id>?username=$FACTORIO_USERNAME&token=$FACTORIO_TOKEN")
   nix hash to-sri --type sha256 "$HASH"
   ```

3. Find the mod's `version` — unzip the prefetched file's `info.json`:

   ```bash
   unzip -p /nix/store/<hash>-<id> '*/info.json' | grep version
   ```

4. Add an entry to `mods.nix`:

   ```nix
   your-mod-name = {
     version = "1.2.3";
     downloadPath = "/download/your-mod-name/<id>";
     sha256 = "sha256-...";
   };
   ```

5. Turn it on:

   ```nix
   services.factorio-server.mods = {
     enable = true;
     your-mod-name = true;
   };
   ```

## Options reference (`services.factorio-server`)

### Core

- `enable` — turn the server on.
- `package` — Factorio package to run (default `pkgs.factorio-headless`, which
  tracks nixpkgs' stable build and can lag behind what mods need).
- `openFirewall` — open the UDP game `port` in the firewall (default `true`).
- `port` — UDP game port (default `34197`).
- `bind` — address to bind to (default `0.0.0.0`).

### Fetching Factorio directly (`build.*`)

- `build.enable` — fetch Factorio straight from factorio.com instead of
  using `package`. No mods.factorio.com login needed for this (only mod
  *downloads* require auth — the headless server binary itself is public).
  Uses `builtins.fetchTarball` (unhashed, impure), so there's no per-version
  hash to maintain — same `--impure` requirement as mod downloads.
- `build.version` — exact version to fetch, e.g. `"2.1.16"`. Omit
  (`null`, the default) for the latest stable release.

  ```nix
  services.factorio-server.build = {
    enable = true;
    version = "2.1.16";
  };
  ```

### Access control

- `admins` — list of player names granted admin.
- `allowedPlayers` — if non-empty, only these players may connect
  (whitelist); empty means open, manageable in-game via `/whitelist`.
- `requireUserVerification` — only allow clients with a valid factorio.com
  account (default `true`).
- `public` — publish on the official matching server (default `false`).
- `lan` — broadcast on LAN (default `true`).
- `username` / `password` / `token` — factorio.com credentials, required if
  `public = true`. Plaintext in the Nix store — prefer `extraSettingsFile`.
- `gamePassword` — password required to join. Same plaintext caveat.

### Save/state

- `saveName` — name of the savegame (default `"default"`).
- `loadLatestSave` — always load the most recent autosave on startup.
- `stateDirName` — directory name under `/var/lib` (default `"factorio"`).
- `autosaveInterval` — minutes between autosaves.
- `nonBlockingSaving` — experimental non-blocking save (risk of corruption).

### Listing

- `gameName` — name shown in the game listing.
- `description` — description shown in the game listing.

### Escape hatches

- `extraSettings` — extra fields merged into `server-settings.json`.
- `extraSettingsFile` — path to a file (e.g. from agenix/sops) merged into
  `server-settings.json` at startup; use this instead of `password`/`token`/
  `gamePassword` to keep credentials out of the Nix store.
- `extraArgs` — extra CLI arguments passed straight to `factorio`.

### RCON (`rcon.*`)

- `rcon.enable` — turn on the RCON remote console.
- `rcon.port` — RCON port (default `27015`).
- `rcon.bind` — address RCON binds to (default `0.0.0.0`).
- `rcon.password` — RCON password. Factorio only accepts this as a plaintext
  CLI argument (no password-file support), so it's visible in the Nix store
  and the unit's process list regardless of how it's set here.
- `rcon.openFirewall` — open `rcon.port` (TCP) in the firewall.

### Mods (`mods.*`)

- `mods.enable` — master switch for mod support.
- `mods.<name>` — one boolean per entry in `mods.nix`; set to `true` to
  install and activate that mod.

## Local testing without deploying

There's no standalone flake here anymore (it lives inside `nix-modules`),
so for poking at the headless binary directly without any of this module's
config, just use nixpkgs:

```bash
nix run nixpkgs#factorio-headless
```

This doesn't exercise `services.factorio-server` at all — that only applies
within a NixOS system build.

## Maintenance skills

This directory ships Claude Code project skills (`.claude/skills/`) for the
recurring maintenance tasks above:

- `/add-factorio-mod` — register a brand-new mod in `mods.nix` from a
  mods.factorio.com download link.
- `/check-factorio-mod-update` — read-only: is a newer version available
  for a mod already in `mods.nix`?
- `/update-factorio-mod` — bump a single registered mod to a new version,
  checking Factorio-version compatibility first (see above) before
  touching anything.
- `/sync-factorio-mods` — bulk-update every registered mod to match a
  target Factorio version in one pass (e.g. after changing `build.version`).

## Troubleshooting

**`factorio.service` crash-looping (`start-limit-hit`)**: almost always a
mod/Factorio version mismatch. Check the real error:

```bash
sudo journalctl -u factorio.service -n 60 --no-pager
```

Look for `Incompatible Factorio version` or `Missing required dependency`
— fix via `/update-factorio-mod` or `/sync-factorio-mods`, or by disabling
the offending mod, then `sudo -E nixos-rebuild switch --flake .#<host>
--impure` again.

**Config change not taking effect after editing this module**: `nix-modules`
is consumed as a flake input elsewhere, so it's pinned in the consuming
flake's lock file — see the two gotchas under Quick start above (refresh
the lock, and `git add` new/edited files before the flake will see them).
