{
  config,
  pkgs,
  lib,
  username,
  # llmAgentPkgs,
  ...
}: let
  # Platform-agnostic paths
  homeDir =
    if pkgs.stdenv.isDarwin
    then "Users/${username}"
    else "/home/${username}";
  ghqRoot = "${homeDir}/ghq";
  dotfilesDir = "${ghqRoot}/github.com/v01d42/dotfiles";

  # Direct symlink (not via Nix store)
  symlink = config.lib.file.mkOutOfStoreSymlink;

  # Custom packages
  # customPkgs = {}
in {
  imports = [
    ./editorconfig.nix
    ./git.nix
  ];
  home = {
    # User info
    inherit username;
    homeDirectory = lib.mkForce homeDir;

    # Home Manager state version.
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "25.11";

    sessionPath = [
      "${homeDir}/.local/bin"
      "${dotfilesDir}/bin"
    ];

    # User packages
    packages =
      lib.optionals pkgs.stdenv.isLinux [
        pkgs.zsh
        pkgs.wslu
      ]
      ++ [
        # Version Manager
        pkgs.gh
        pkgs.ghq

        # Search
        pkgs.fd

        # File viewers
        pkgs.jq

        # System
        pkgs.wget

        # Language Runtimes
        pkgs.deno
        pkgs.go
        pkgs.nodejs
        pkgs.python3
        pkgs.uv

        # Linters & Formatters
        pkgs.alejandra

        # LSP

        # Editor
        pkgs.neovim
        pkgs.vim

        # Build tools
        pkgs.cmake
        pkgs.gcc
      ]
      # AI coding agent
      ++ [
        pkgs.claude-code
      ]
  };

  xdg.configFile = {
    # "ccstatusline".source = symlink "${dotfilesDir}/config/ccstatusline";
    # "claude".source = symlink "${dotfilesDir}/config/claude";
    # "efm-langserver".source = symlink "${dotfilesDir}/config/efm-langserver";
    "nvim".source = symlink "${dotfilesDir}/config/nvim";
    # "rumdl/rumdl.toml".source = symlink "${dotfilesDir}/.rumdl.toml";
    # "skk".source = symlink "${dotfilesDir}/config/skk";
    # "tmux".source = symlink "${dotfilesDir}/config/tmux";
    # "vde".source = symlink "${dotfilesDir}/config/vde";
    "vim".source = symlink "${dotfilesDir}/config/vim";
    # "wezterm".source = symlink "${dotfilesDir}/config/wezterm";
    # "zeno".source = symlink "${dotfilesDir}/config/zeno";
  };

  programs = {
    # Let Home Manager manage itself
    home-manager.enable = true;

    # direnv (auto-activate devShell when cd into project)
    # Note: zsh hook is handled by zinit turbo mode for faster startup
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = false; # Handled by zinit turbo
    };

    # zsh (managed by home-manager)
    zsh = {
      enable = true;
      enableCompletion = false; # Handled by zinit turbo mode

      # Environment variables
      sessionVariables = {
        # CLAUDE_CONFIG_DIR = "${dotfilesDir}/config/claude";
        DENO_NO_PROMPT = "1";
        DENO_NO_UPDATE_CHECK = "1";
        EDITOR = "vim";
        # FZF_DEFAULT_OPTS = "--reverse --bind 'ctrl-y:accept'";
        NVIM_APPNAME = "nvim";
        TZ = "Asia/Tokyo";
        VISUAL = "vim";
        XDG_CACHE_HOME = "$HOME/.cache";
        XDG_CONFIG_HOME = "$HOME/.config";
      };

      # History
      history = {
        extended = true;
        ignoreAllDups = true;
        ignoreDups = true;
        ignoreSpace = true;
        path = "$HOME/.zsh_history";
        save = 1000000;
        share = true;
        size = 1000000;
      };

      # ~/.zshenv additions (dynamic processing)
      # NOTE: ''${VAR} escapes to ${VAR} in shell (prevents nix interpolation)
      envExtra = ''
        # Nix PATH recovery (in case macOS update overwrites /etc/zshenv)
        if [ -z "''${__NIX_DARWIN_SET_ENVIRONMENT_DONE-}" ]; then
          if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
            . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
          fi
        fi

        # locale
        if locale -a 2>/dev/null | grep -q "en_US.UTF-8"; then
          export LC_ALL=en_US.UTF-8
        else
          export LC_ALL=C.UTF-8
        fi

        # Homebrew PATH (macOS only)
        if [[ -d /opt/homebrew ]]; then
          export PATH=/opt/homebrew/bin:"''${PATH}"
        fi

        # Local config
        if [[ -f ~/.zshenv.local ]]; then
          source ~/.zshenv.local
        fi
      '';

      # ~/.zshrc additions
      initContent = ''
        # Disable Ctrl-D to exit
        setopt IGNORE_EOF

        # History options (values are set by home-manager)
        setopt append_history
        setopt hist_fcntl_lock
        setopt hist_reduce_blanks
        setopt hist_save_no_dups

        # Source modular configs
        source ${dotfilesDir}/nix/zsh/keybind.zsh
        source ${dotfilesDir}/nix/zsh/zinit.zsh
        source ${dotfilesDir}/nix/zsh/prompt.zsh
        # source ${dotfilesDir}/nix/zsh/aws.zsh

        # Local config
        if [[ -f ~/.zshrc.local ]]; then
          source ~/.zshrc.local
        fi
      '';
    };
  };

  # ============================================================================
  # Activation scripts (run on darwin-rebuild switch / home-manager switch)
  # ============================================================================
  home.activation = let
    npm = "${pkgs.nodejs}/bin/npm";
    npmPrefix = "${homeDir}/.local";
    ghq = "${pkgs.ghq}/bin/ghq";
    git = "${pkgs.git}/bin/git";
    fd = "${pkgs.fd}/bin/fd";
    ghqListEssential = "${dotfilesDir}/nix/ghq-list-essential.txt";
    tpmDir = "${dotfilesDir}/config/tmux/plugins/tpm";
  in {
    # 0. Clean temporary files (node caches for security)
    cleanTemporaryFiles = lib.hm.dag.entryAfter ["writeBoundary"] ''
      echo "Cleaning temporary files..."
      # Node.js caches
      rm -rf "${homeDir}/.npm"
      ${lib.optionalString pkgs.stdenv.isDarwin ''
        rm -rf "${homeDir}/Library/Caches/deno"
        ${fd} ".DS_Store" ${ghqRoot} --hidden --no-ignore | xargs rm -f || true
        /usr/bin/xattr -rc ${ghqRoot} || true
      ''}
    '';

    # 1. Clone essential repositories (ghq-get-essential)
    # Note: ghq requires git in PATH
    ghqGetEssential = lib.hm.dag.entryAfter ["writeBoundary"] ''
      export PATH="${pkgs.git}/bin:$PATH"
      if [ -f "${ghqListEssential}" ]; then
        echo "Cloning essential repositories..."
        ${ghq} get -p < "${ghqListEssential}" || true
      fi
    '';

    # 2. Start ssh-agent if not running (Linux only)
    # cf. https://inno-tech-life.com/dev/infra/wsl2-ssh-agent/
    # startSshAgent = lib.hm.dag.entryAfter ["writeBoundary"] (
    #   lib.optionalString pkgs.stdenv.isLinux ''
    #     if [ -z "''${SSH_AUTH_SOCK:-}" ]; then
    #       eval $(${pkgs.openssh}/bin/ssh-agent)
    #     fi
    #   ''
    # );

    # 3. Install/update npm packages (after safe-chain, so they get scanned)
    installNpmPackages = lib.hm.dag.entryAfter ["writeBoundary"] ''
      export PATH="${npmPrefix}/bin:${pkgs.nodejs}/bin:$PATH"
      # AI tools moved to Nix: claude-code, ccusage, codex, copilot, gemini-cli
      NPM_PACKAGES=(
        "@devcontainers/cli"
        "vde-layout"
      )

      # Install missing packages
      for pkg in "''${NPM_PACKAGES[@]}"; do
        if ! ${npm} --prefix ${npmPrefix} list -g --depth=0 "$pkg" >/dev/null 2>&1; then
          echo "Installing $pkg..."
          ${npm} --prefix ${npmPrefix} install -g "$pkg"
        fi
      done

      # Update outdated packages in one batch
      outdated=$(${npm} --prefix ${npmPrefix} outdated -g --parseable --depth=0 2>/dev/null | cut -d: -f4 || true)
      if [ -n "$outdated" ]; then
        echo "Updating outdated packages: $outdated"
        echo "$outdated" | xargs ${npm} --prefix ${npmPrefix} install -g
      fi
    '';
  };
}
