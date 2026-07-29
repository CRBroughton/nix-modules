# nix-modules

Shared home-manager modules for personal and work devices.

## Modules

- **helix** — Helix editor with LSP support (TypeScript, Vue, Go, Odin, Nix, Tailwind)
- **zellij** — Zellij terminal multiplexer, Vitesse Dark themed
- **neovim** — Neovim with lazy.nvim, opt-in LSP languages (TypeScript, Vue, Go, Nix, Tailwind) and plugins (Telescope, Vitesse theme)

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
    inputs.nix-modules.homeManagerModules.neovim
  ];

  programs.helix-modules = {
    enable = true;
    languages.odin.enable = false;
  };

  programs.zellij-modules.enable = true;

  programs.neovim-modules = {
    enable = true;
    languages = {
      nix.enable = true;
      go.enable = true;
    };
    plugins.telescope.enable = true;
  };
}
```

#### NixOS + home-manager

Add to `sharedModules` in your flake so all users get access:

```nix
# flake.nix / lib
home-manager.sharedModules = [
  inputs.nix-modules.homeManagerModules.helix
  inputs.nix-modules.homeManagerModules.zellij
  inputs.nix-modules.homeManagerModules.neovim
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

## Neovim options

Everything is opt-in and defaults to `false`.

| Option | Description |
|--------|-------------|
| `languages.nix.enable` | Nix (nil_ls) |
| `languages.go.enable` | Go (gopls) |
| `languages.typescript.enable` | TypeScript (ts_ls + eslint) |
| `languages.vue.enable` | Vue (vue_ls, requires `languages.typescript.enable`) |
| `languages.tailwind.enable` | Tailwind CSS LSP |
| `plugins.telescope.enable` | Telescope fuzzy finder |
| `plugins.theme.enable` | Vitesse colourscheme |
| `extraPlugins` | List of packages providing extra lazy.nvim plugin specs (`pkg.name` / `pkg.src`) |
| `treesitterParsers` | Extra treesitter parsers to install, on top of `lua`/`vim`/`vimdoc` and whatever the enabled languages request |
