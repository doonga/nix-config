{ lib, pkgs, pkgs-unstable, myPkgs, ... }:

let
  vscode-extensions = (import ../../editor/vscode/extensions.nix){pkgs = pkgs;};
in
{
  modules.users.todd.editor.vscode = {
    enable = true;
    package = pkgs-unstable.vscode;

    extensions = (with vscode-extensions; [
      eamodio.gitlens
      golang.go
      fnando.linter
      # github.copilot
      hashicorp.terraform
      jnoortheen.nix-ide
      luisfontes19.vscode-swissknife
      mrmlnc.vscode-json5
      ms-azuretools.vscode-docker
      ms-vscode-remote.remote-containers
      ms-vscode-remote.remote-ssh
      redhat.ansible
      ms-python.python
      ms-python.vscode-pylance
    ]);

    config = {
      # Editor settings
      editor = {
        fontFamily = lib.strings.concatStringsSep "," [
          "'Monaspace Krypton'"
          "'Font Awesome 6 Free Solid'"
        ];
        fontLigatures = "'calt', 'liga', 'dlig', 'ss01', 'ss02', 'ss03', 'ss06'";
      };
      # Extension settings
      ansible = {
        python.interpreterPath = ".venv/bin/python";
      };

      linter = {
        linters = {
          yamllint = {
            configFiles = [
              ".yamllint.yml"
              ".yamllint.yaml"
              ".yamllint"
              ".ci/yamllint/.yamllint.yaml"
            ];
          };
        };
      };

      qalc = {
        output.displayCommas = false;
        output.precision = 0;
        output.notation = "auto";
      };
    };
  };

  modules.users.todd.shell.rtx = {
    enable = true;
    package = pkgs-unstable.rtx;
  };

  modules.users.todd.virtualisation.colima = {
    enable = true;
    enableService = true;
    package = pkgs-unstable.colima;
  };

  home-manager.users.todd.home.packages = [
    pkgs.envsubst
    pkgs.go-task
  ] ++ [
    myPkgs.harlequin
  ];
}
