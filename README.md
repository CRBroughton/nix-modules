# nix-modules

Shared home-manager modules for personal and work devices.

## Modules

- **helix** — Helix editor with LSP support (TypeScript, Vue, Go, Odin, Nix, Tailwind, UnoCSS)
- **zellij** — Zellij terminal multiplexer, Vitesse Dark themed

## Usage

### 1. Add as a flake input

```nix
# flake.nix
inputs = {
  nix-modules = {
    url = "github:CRBroughton/nix-modules";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};
```

For local development, use a path input instead:

```nix
nix-modules = {
  url = "path:/path/to/nix-modules";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

### 2. Import into home-manager

#### Standalone home-manager (e.g. Mac)

```nix
# home.nix
{ inputs, ... }:
{
  imports = [
    inputs.nix-modules.homeManagerModules.helix
    inputs.nix-modules.homeManagerModules.zellij
  ];

  programs.helix-modules = {
    enable = true;
    languages.odin.enable = false;
  };

  programs.zellij-modules.enable = true;
}
```

#### NixOS + home-manager

Add to `sharedModules` in your flake so all users get access:

```nix
# flake.nix / lib
home-manager.sharedModules = [
  inputs.nix-modules.homeManagerModules.helix
  inputs.nix-modules.homeManagerModules.zellij
];
```

Then enable per-user or per-host:

```nix
programs.helix-modules = {
  enable = true;
  languages = {
    typescript.enable = true;
    vue.enable = true;
    go.enable = false;
    odin.enable = false;
    nix.enable = true;
    tailwind.enable = false;
    unocss.enable = true;
  };
};

programs.zellij-modules.enable = true;
```

## Helix language options

All languages default to `true`. Disable individually:

| Option | Description |
|--------|-------------|
| `languages.typescript.enable` | TypeScript + TSX (eslint, tsserver) |
| `languages.vue.enable` | Vue 3 (volar, tsserver plugin) |
| `languages.go.enable` | Go (gopls, gofumpt) |
| `languages.odin.enable` | Odin (ols) |
| `languages.nix.enable` | Nix (nixd, nixfmt) |
| `languages.tailwind.enable` | Tailwind CSS LSP |
| `languages.unocss.enable` | UnoCSS LSP |
