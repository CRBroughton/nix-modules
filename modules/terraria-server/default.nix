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
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Path to the world file (`.wld`) to load. If it doesn't exist yet, a
        new world is auto-created here at `autoCreatedWorldSize`.
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
  };
}
