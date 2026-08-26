# nix-modules

Shared home-manager modules for personal and work devices.

## Modules

- **helix** — Helix editor with LSP support (TypeScript, Vue, Go, Odin, Nix, Tailwind)
- **zellij** — Zellij terminal multiplexer, Vitesse Dark themed
- **neovim** — Neovim with lazy.nvim, opt-in LSP languages and plugins

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

### Languages

Enabling a language installs its LSP, formatter, and treesitter parser automatically.

| Option | Description |
|--------|-------------|
| `languages.typescript.enable` | TypeScript + TSX (ts_ls, eslint_d) |
| `languages.vue.enable` | Vue 3 (vue_ls — requires `typescript.enable`) |
| `languages.go.enable` | Go (gopls, goimports) |
| `languages.nix.enable` | Nix (nil_ls, nixfmt) |
| `languages.odin.enable` | Odin (ols) |
| `languages.tailwind.enable` | Tailwind CSS LSP |
| `languages.gameboy.enable` | Game Boy assembly (RGBDS, vim-rgbds syntax) |

### Plugins

| Option | Description |
|--------|-------------|
| `plugins.bufferline.enable` | Buffer tab bar (`<S-h>`/`<S-l>` to cycle) |
| `plugins.conventional-commit.enable` | Interactive conventional commit picker (`<leader>gc`) |
| `plugins.flash.enable` | Jump-to-label motion (`s`, `S`) |
| `plugins.harpoon.enable` | File bookmarks — harpoon2 (`<leader>h`) |
| `plugins.telescope.enable` | Fuzzy finder (`<leader>f`) |
| `plugins.theme.enable` | Vitesse colourscheme |
| `plugins.which-key.enable` | Keymap popup on `<Space>`, full list via `<leader>?` |

### Core (always active when `enable = true`)

- `mapleader = ' '` (Space)
- LSP keymaps: `gd` go to definition, `K` hover, `<leader>lr` rename, `<leader>la` code action, `<leader>ld` diagnostics, `[d`/`]d` navigate diagnostics
- Format on save via conform.nvim (formatters installed per language)
- `<C-s>` save

### Advanced

| Option | Description |
|--------|-------------|
| `extraPlugins` | List of packages providing extra lazy.nvim plugin specs (`pkg.name` / `pkg.src`) |
| `treesitterParsers` | Extra treesitter parsers on top of `lua`/`vim`/`vimdoc` and language defaults |
