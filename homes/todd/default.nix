{
  pkgs,
  lib,
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
          "gateway.greyrock.io" = {
            port = 22;
            user = "vyos";
          };
          "nas.greyrock.io" = {
            port = 22;
            user = "todd";
            forwardAgent = true;
          };
        };
      };
    };

    shell = {
      fish.enable = true;

      git = {
        enable = true;
        username = "Todd Punderson";
        email = "agile.car7544@undercovermail.org";
        signingKey = "B6F2966E0B5ECD11";
      };

      go-task.enable = true;

      mise = {
        enable = true;
        package = pkgs.unstable.mise;
      };
    };
  };
}
