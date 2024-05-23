{
  pkgs,
  lib,
  config,
  inputs,
  hostname,
  flake-packages,
  ...
}:
{
  imports = [
    ../_modules

    ./secrets
    ./hosts/${hostname}.nix
  ];

  modules = {
    editor = {
      nvim = {
        enable = true;
        package = flake-packages.${pkgs.system}.nvim;
        makeDefaultEditor = true;
      };

      vscode = {
        userSettings = lib.importJSON ./config/editor/vscode/settings.json;
        extensions = let
          inherit (inputs.nix-vscode-extensions.extensions.${pkgs.system}) vscode-marketplace;
        in
          with vscode-marketplace; [
            # Themes
            catppuccin.catppuccin-vsc
            thang-nm.catppuccin-perfect-icons

            # Language support
            golang.go
            hashicorp.terraform
            helm-ls.helm-ls
            jnoortheen.nix-ide
            mrmlnc.vscode-json5
            ms-azuretools.vscode-docker
            ms-python.python
            redhat.ansible
            redhat.vscode-yaml
            tamasfe.even-better-toml

            # Formatters
            esbenp.prettier-vscode

            # Linters
            davidanson.vscode-markdownlint
            fnando.linter

            # Remote development
            ms-vscode-remote.remote-containers
            ms-vscode-remote.remote-ssh

            # Other
            eamodio.gitlens
            gruntfuggly.todo-tree
            ionutvmi.path-autocomplete
            luisfontes19.vscode-swissknife
            ms-kubernetes-tools.vscode-kubernetes-tools
            shipitsmarter.sops-edit
          ];
      };
    };

    security = {
      ssh = {
        enable = true;
        matchBlocks = {
          "nas.greyrock.io" = {
            port = 22;
            user = "todd";
            forwardAgent = true;
          };
          "dns1.greyrock.io" = {
            port = 22;
            user = "todd";
            forwardAgent = true;
          };
        };
      };
    };

    shell = {
      atuin = {
        enable = true;
        package = pkgs.unstable.atuin;
        flags = [
          "--disable-up-arrow"
        ];
        settings = {
          sync_address = "https://atuin.greyrock.casa";
          key_path = config.sops.secrets.atuin_key.path;
          auto_sync = true;
          sync_frequency = "1m";
          search_mode = "fuzzy";
          sync = {
            records = true;
          };
        };
      };

      fish.enable = true;

      git = {
        enable = true;
        username = "Todd Punderson";
        email = "agile.car7544@undercovermail.org";
        signingKey = "B6F2966E0B5ECD11";
      };

      go-task.enable = true;
    };

    themes = {
      catppuccin = {
        enable = true;
        flavour = "macchiato";
      };
    };
  };
}
