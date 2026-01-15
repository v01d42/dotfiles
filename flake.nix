{
  description = "v01d's home-manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-code-overlay = {
      url = "github:ryoppippi/claude-code-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # neovim-nighty
    # neovim-nighty-overlay.url = "github:nix-community/neovim-nighty-overlay"
    # vim-overlay.url = "github:kawarimidoll/vim-overlay"

    # AI coding agents
    # llm-agent.url = "github:numtide/llm-agent.nix"
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    # neovim-nighty-overlay
    # vim-overlay
    claude-code-overlay,
    # llm-agent
    ...
    }: let
      systems = ["x86_64-linux" "aarch64-darwin"];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in {

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

      # Custom packages

      # nix develop
      # devShells = forAllSystems ()

      # home-manager switch --flake '.#ubuntu' --impure
      # For Ubuntu / WSL2
      homeConfigurations."ubuntu" = let
        system = "x86_64-linux";
        pkgs = import nixpkgs{
          inherit system;
          config.allowUnfree = true;
          overlays = [
          #  neovim-nighty-overlay.overlays.default
          #  (vim-overlay.overlays.feature {
          #    lua = true;
          #    python3 = true;
          #  })
            claude-code-overlay.overlays.default
          ];
        };
        username = builtins.getEnv "USER";
      in
        home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit username;
          # llmAgentPkgs = llm-agent.packages.${system};
        };
        modules = [
          ./nix/home.nix
        ];
      };
    };
}
