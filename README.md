# dotfiles

[![DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/v01d42/dotfiles)

My personal dotfiles managed with Nix and home-manager.

## Nix Configuration

### Structure

```
.
├── config/
│   └── nvim/      # Neovim configuration
├── nix/
│   ├── home.nix   # home-manager configuration
│   └── *.nix      # Module files
└── flake.nix      # Nix flake
```

### Initial Setup

#### Linux

1. Install [Determinate Nix](https://github.com/DeterminateSystems/nix-installer):

   ```sh
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```

2. Clone this repository:

   ```sh
   git clone https://github.com/v01d42/dotfiles.git ~/ghq/github.com/v01d42/dotfiles
   cd ~/ghq/github.com/v01d42/dotfiles
   ```

3. Apply Home Manager configuration:

   ```sh
   nix run home-manager -- switch --flake '.#ubuntu' --impure
   ```

4. Set zsh as default shell:
   ```sh
   echo $(which zsh) | sudo tee -a /etc/shells
   chsh -s $(which zsh)
   ```

5. Set PC-specific Git Config:
   ```sh
   touch ~/.gitconfig
   git config --global user.name "Your Name"
   git config --global user.email "your@email.com"
   ```

#### macOS

Not supported yet...

### Post Setup

#### 1. gh (GitHub CLI)
   ```sh
   gh auth login
   ```

