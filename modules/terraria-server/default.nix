{ config, lib, pkgs, ... }:
let
  cfg = config.services.terraria-server;
in
{
  options.services.terraria-server = {
    enable = lib.mkEnableOption "Terraria dedicated server";

    package = lib.mkPackageOption pkgs "terraria-server" { };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to open `port` (TCP+UDP) in the firewall.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 7777;
      description = "Port to listen on.";
    };

    maxPlayers = lib.mkOption {
      type = lib.types.ints.u8;
      default = 255;
      description = "Max number of players (1-255).";
    };

    password = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Server password. `null` for no password. Plaintext in the Nix
        store — this is passed as a CLI argument, same caveat as Factorio's
        RCON password.
      '';
    };

    messageOfTheDay = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Message of the day shown to players.";
    };

    worldPath = lib.mkOption {
      type = lib.types.path;
      default = "${cfg.dataDir}/Worlds/world.wld";
      defaultText = lib.literalExpression ''"''${dataDir}/Worlds/world.wld"'';
      description = ''
        Path to the world file (`.wld`) to load. If it doesn't exist yet, a
        new world is auto-created here at `autoCreatedWorldSize`.

        nixpkgs' underlying `services.terraria` only passes `-autocreate` to
        the server when `worldPath` is set — leaving this `null` makes the
        server hang at an interactive "Choose World" prompt instead of
        starting, so unlike upstream this defaults to a real path rather
        than `null`.
      '';
    };

    autoCreatedWorldSize = lib.mkOption {
      type = lib.types.enum [ "small" "medium" "large" ];
      default = "medium";
      description = "Size of the auto-created world if `worldPath` doesn't exist yet.";
    };

    banListPath = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to the ban list.";
    };

    secure = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Adds additional cheat protection.";
    };

    noUPnP = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Disable automatic Universal Plug and Play.";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/terraria";
      description = "State data directory.";
    };

    difficulty = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ "classic" "expert" "master" "journey" ]);
      default = null;
      description = ''
        World difficulty, applied only when the world at `worldPath` is
        first created — it has no effect on an already-existing world file
        (delete it to regenerate with a new difficulty). `null` uses the
        server's own default (classic).

        Not a nixpkgs `services.terraria` option — that module has no
        generic escape hatch for extra CLI flags, so this overrides its
        computed `ExecStart` to inject `-difficulty`. Fragile against
        nixpkgs terraria.nix internals changing; re-check this override if
        upgrading nixpkgs breaks Terraria activation.
      '';
    };

    worldSeed = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        World seed, applied only when the world at `worldPath` is first
        created — like `difficulty`, it has no effect on an already-existing
        world file (delete it to regenerate with a new seed). Accepts
        numeric seeds and Terraria's special string seeds (e.g.
        "getfixedboi"). `null` uses a random seed.

        Not a nixpkgs `services.terraria` option — injected into the same
        `ExecStart` override as `difficulty`, with the same fragility
        caveat.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [ "terraria-server" ];

    services.terraria = {
      enable = true;
      inherit (cfg)
        package openFirewall port maxPlayers password messageOfTheDay
        worldPath autoCreatedWorldSize banListPath secure noUPnP dataDir;
    };

    # Reimplements nixpkgs' terraria.nix ExecStart construction (its
    # `flags`/`tmuxCmd` locals aren't exposed) so `-difficulty`/`-seed` can
    # be injected — that module has no generic extra-args escape hatch.
    systemd.services.terraria.serviceConfig.ExecStart = lib.mkIf (cfg.difficulty != null || cfg.worldSeed != null) (
      let
        difficultyNum = {
          classic = 0;
          expert = 1;
          master = 2;
          journey = 3;
        };
        worldSizeMap = { small = 1; medium = 2; large = 3; };
        valFlag = name: val:
          lib.optionalString (val != null) "-${name} \"${lib.escape [ "\\" "\"" ] (toString val)}\"";
        boolFlag = name: val: lib.optionalString val "-${name}";
        flags = [
          (valFlag "port" cfg.port)
          (valFlag "maxPlayers" cfg.maxPlayers)
          (valFlag "password" cfg.password)
          (valFlag "motd" cfg.messageOfTheDay)
          (valFlag "world" cfg.worldPath)
          (valFlag "autocreate" worldSizeMap.${cfg.autoCreatedWorldSize})
          (valFlag "banlist" cfg.banListPath)
          (boolFlag "secure" cfg.secure)
          (boolFlag "noupnp" cfg.noUPnP)
          (valFlag "difficulty" (if cfg.difficulty != null then difficultyNum.${cfg.difficulty} else null))
          (valFlag "seed" cfg.worldSeed)
        ];
        tmuxCmd = "${lib.getExe pkgs.tmux} -S ${lib.escapeShellArg cfg.dataDir}/terraria.sock";
      in
      lib.mkForce "${tmuxCmd} new -d ${lib.getExe cfg.package} ${lib.concatStringsSep " " flags}"
    );
  };
}
