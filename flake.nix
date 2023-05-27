{
  description = "Data Analytics Portfolio Flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    rust-overlay,
    nix-vscode-extensions,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      overlays = [
        (import rust-overlay)
        (self: super: {
          rustToolchain = super.rust-bin.fromRustupToolchainFile ./config/flake.toml;
          # rustToolchain = super.rust-bin.fromRustupToolchainFile ./rust-toolchain;
        })
      ];
      pkgs = import nixpkgs {
        inherit system overlays;
        config = {
          allowUnfree = true;
          allowAliases = true;
        };
      };
    in {
      devShell = pkgs.mkShell {
        packages = let
          toolkitGeneral = with pkgs; [
            #/> Authentication <\#
            gnome.seahorse
            gnome.gnome-keyring
            gnome.libgnome-keyring

            #/> Test <\#
            hello
          ];
          toolkitShell = with pkgs; [
            #/> Shell <\#
            shfmt
            exa
            ripgrep
            bat
            rust-script
            direnv
            taplo
            jql
          ];
          toolkitRust = with pkgs; [
            rustToolchain
            openssl
            pkg-config
            cargo-edit
            cargo-watch
            cargo-generate
          ];
          toolkitData = with pkgs; [
            #/> Collection & Storage <\#
            postgresql_15
            sqlx-cli
            surrealdb

            #/> Preparation & Transformation <\#

            #/> Visualization <\#
            grafana
            # jupyter
            # evcxr
          ];
          toolkitVSCode = pkgs.vscode-with-extensions.override {
            vscodeExtensions = with pkgs.vscode-extensions; [
              #/> Nix
              bbenoist.nix
              kamadorueda.alejandra
              mkhl.direnv

              #/> Rust
              matklad.rust-analyzer
              serayuzgur.crates

              #/> Toml
              tamasfe.even-better-toml
              eamodio.gitlens
              vscode-icons-team.vscode-icons

              #/> Data
              mechatroner.rainbow-csv
              grapecity.gc-excelviewer
              cweijan.vscode-database-client2
              ms-toolsai.jupyter

              #/> AI
              genieai.chatgpt-vscode
              chris-hayes.chatgpt-reborn

              #/> VSC
              github.codespaces
              codezombiech.gitignore

              #/> Shell
              foxundermoon.shell-format
              timonwong.shellcheck

              #/> Theming
              oderwat.indent-rainbow
              kamikillerto.vscode-colorize
              ibm.output-colorizer
              gruntfuggly.todo-tree
              # vscodevim.vim
            ];
          };
        in [
          toolkitGeneral
          toolkitRust
          toolkitData
          toolkitVSCode
        ];

        inputsFrom = [];
      };
    });
}
