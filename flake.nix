{
  description = "Shared home-manager and NixOS modules";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }: {
    homeManagerModules = {
      helix  = import ./modules/helix;
      zellij = import ./modules/zellij;
      neovim = import ./modules/neovim;
    };

    nixosModules = {
      factorio-server = import ./modules/factorio-server;
      terraria-server = import ./modules/terraria-server;
    };
  };
}
