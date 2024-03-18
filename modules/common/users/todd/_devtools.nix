{
  lib,
  pkgs,
  pkgs-unstable,
  myPackages,
  ...
}:
{
  modules.users.todd.editor.vscode = {
    enable = true;
    package = pkgs-unstable.vscode;

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

  modules.users.todd.shell.mise = {
    enable = true;
    package = pkgs-unstable.mise;
    config = {
      experimental = true;
      python_venv_auto_create = true;
    };
  };

  modules.users.todd.virtualisation.colima = {
    enable = true;
    enableService = true;
    package = pkgs-unstable.colima;
  };

  home-manager.users.todd.home.packages = [
    pkgs-unstable.deploy-rs.deploy-rs
    pkgs.envsubst
    pkgs.go-task
    pkgs.nvd
  ] ++ [
    myPackages.harlequin
  ];
}
