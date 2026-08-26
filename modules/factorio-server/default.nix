{ config, lib, pkgs, ... }:
let
  cfg = config.services.factorio-server;
  modRegistry = import ./mods.nix;

  # Credentials for mods.factorio.com, read from the environment so they
  # never end up in this file or the store's .drv files. Requires --impure
  # (e.g. `nixos-rebuild switch --impure`):
  #   export FACTORIO_USERNAME=yourname
  #   export FACTORIO_TOKEN=yourtoken   # from factorio.com/profile
  factorioUsername = builtins.getEnv "FACTORIO_USERNAME";
  factorioToken = builtins.getEnv "FACTORIO_TOKEN";

  # nixpkgs' own `services.factorio.mods` machinery walks each derivation's
  # `.deps` list to pull in dependencies, so mods must be built via the
  # factorio-utils modDrv builder (which sets `deps = [ ]` by default) rather
  # than a plain runCommand derivation.
  buildMod = pkgs.factorio-utils.modDrv {
    allRecommendedMods = false;
    allOptionalMods = false;
  };

  mkMod = { name, version, downloadPath, sha256 }:
    buildMod {
      name = "${name}-${version}";
      src = pkgs.fetchurl {
        url = "https://mods.factorio.com${downloadPath}?username=${factorioUsername}&token=${factorioToken}";
        name = "${name}_${version}.zip";
        inherit sha256;
      };
    };

  selectedMods = lib.filterAttrs (name: _: cfg.mods.${name} or false) modRegistry;

  # Fetches a Factorio headless build directly from factorio.com instead of
  # using nixpkgs' packaged version (which tracks stable and can lag behind
  # what mods require). No login needed — only mod downloads require auth.
  # Uses builtins.fetchTarball (unhashed, impure) so no manual hash upkeep is
  # needed per version; requires --impure the same as mod downloads do.
  webBuildVersion = if cfg.build.version != null then cfg.build.version else "stable";

  webBuild = pkgs.stdenv.mkDerivation {
    pname = "factorio-headless";
    version = webBuildVersion;

    src = builtins.fetchTarball {
      url = "https://factorio.com/get-download/${webBuildVersion}/headless/linux64";
    };

    dontBuild = true;
    nativeBuildInputs = [ pkgs.patchelf ];

    installPhase = ''
      mkdir -p $out/bin $out/share/factorio
      cp -a data $out/share/factorio
      cp -a bin/x64/factorio $out/bin/factorio
      patchelf \
        --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
        $out/bin/factorio
    '';

    meta = {
      description = "Factorio headless dedicated server, fetched directly from factorio.com";
      license = lib.licenses.unfree;
      platforms = [ "x86_64-linux" ];
      mainProgram = "factorio";
    };
  };
in
{
  options.services.factorio-server = {
    enable = lib.mkEnableOption "Factorio dedicated server";

    package = lib.mkPackageOption pkgs "factorio-headless" {
      example = "factorio-headless-experimental";
    };

    build = {
      enable = lib.mkEnableOption ''
        fetching Factorio directly from factorio.com instead of using
        `package` (nixpkgs' build, which tracks stable and can lag behind
        what mods require)
      '';

      version = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "2.1.16";
        description = ''
          Exact Factorio version to fetch from factorio.com. Omit for the
          latest stable release.
        '';
      };
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to open the game port in the firewall.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 34197;
      description = "UDP port the server listens on.";
    };

    bind = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      description = "Address the server should bind to.";
    };

    admins = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "username" ];
      description = "Player names granted admin.";
    };

    allowedPlayers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "Rseding91" "Oxyd" ];
      description = "If non-empty, only these players may connect (whitelist).";
    };

    saveName = lib.mkOption {
      type = lib.types.str;
      default = "default";
      description = "Name of the savegame used by the server.";
    };

    loadLatestSave = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Always load the most recent autosave on startup.";
    };

    stateDirName = lib.mkOption {
      type = lib.types.str;
      default = "factorio";
      description = "Name of the directory under /var/lib holding saves and mods.";
    };

    gameName = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "Nix Factorio Server";
      description = "Name of the game as it appears in the game listing.";
    };

    description = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "Managed by NixOS/nix flake";
      description = "Description of the game shown in the listing.";
    };

    public = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Publish the game on the official Factorio matching server.";
    };

    lan = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Broadcast the game on LAN.";
    };

    username = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        factorio.com username. Required for `public = true`.
        Insecure (plaintext in the Nix store) — prefer `extraSettingsFile`.
      '';
    };

    password = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        factorio.com password. Required for `public = true`.
        Insecure (plaintext in the Nix store) — prefer `extraSettingsFile`.
      '';
    };

    token = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "factorio.com auth token, usable instead of `password`.";
    };

    gamePassword = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Password required to join the game.
        Insecure (plaintext in the Nix store) — prefer `extraSettingsFile`.
      '';
    };

    requireUserVerification = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Only allow clients with a valid factorio.com account.";
    };

    autosaveInterval = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = null;
      example = 10;
      description = "Autosave interval in minutes.";
    };

    nonBlockingSaving = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Experimental: fork to save so the game doesn't pause. Risk of save corruption.";
    };

    extraSettings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      example = { max_players = 64; };
      description = "Extra fields merged into server-settings.json.";
    };

    extraSettingsFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Path to a file (e.g. from agenix/sops) merged into server-settings.json
        at startup. Use this instead of `password`/`token`/`gamePassword` to
        keep credentials out of the Nix store.
      '';
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra command line arguments passed to factorio.";
    };

    rcon = {
      enable = lib.mkEnableOption "RCON remote console";

      port = lib.mkOption {
        type = lib.types.port;
        default = 27015;
        description = "Port to use for RCON.";
      };

      bind = lib.mkOption {
        type = lib.types.str;
        default = "0.0.0.0";
        description = "Address RCON should bind to.";
      };

      password = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = ''
          RCON password. Factorio only accepts this as a plaintext CLI
          argument (no password-file support), so it is visible in the
          Nix store and in the unit's process list regardless of how it's
          set here.
        '';
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to open the RCON port in the firewall.";
      };
    };

    mods = lib.mkOption {
      default = { };
      description = ''
        Mod selection. Set `enable = true` plus individual mod names (from
        mods.nix) to `true` to install them.
      '';
      type = lib.types.submodule {
        options = {
          enable = lib.mkEnableOption "mod support";
        } // lib.mapAttrs
          (name: _: lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable the ${name} mod.";
          })
          modRegistry;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [ "factorio-headless" ];

    services.factorio = {
      enable = true;
      package = if cfg.build.enable then webBuild else cfg.package;

      inherit (cfg)
        openFirewall port bind admins allowedPlayers saveName
        loadLatestSave stateDirName public lan username password token
        requireUserVerification nonBlockingSaving extraSettings
        extraSettingsFile;

      game-name = cfg.gameName;
      description = cfg.description;
      game-password = cfg.gamePassword;
      autosave-interval = cfg.autosaveInterval;

      mods = lib.optionals cfg.mods.enable
        (lib.mapAttrsToList (name: modDef: mkMod (modDef // { inherit name; })) selectedMods);

      extraArgs = cfg.extraArgs
        ++ lib.optional cfg.rcon.enable
          "--rcon-bind=${cfg.rcon.bind}:${toString cfg.rcon.port}"
        ++ lib.optional (cfg.rcon.enable && cfg.rcon.password != null)
          "--rcon-password=${cfg.rcon.password}";
    };

    networking.firewall.allowedTCPPorts =
      lib.optional (cfg.rcon.enable && cfg.rcon.openFirewall) cfg.rcon.port;
  };
}
