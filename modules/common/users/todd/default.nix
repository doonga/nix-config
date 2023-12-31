args@{ pkgs, pkgs-unstable, vscode-extensions, myPkgs, lib, config, ... }:
with lib;

let
  cfg = config.modules.users.todd;
in {
  imports = [
    ( import ../../home-manager { username="todd"; } )
  ];

  options.modules.users.todd = {
    enable = mkEnableOption "todd";
    enableDevTools = mkEnableOption "Enable dev tools" // {
      default = false;
    };
    enableKubernetesTools = mkEnableOption "Enable k8s tools" // {
      default = false;
    };
  };

  config = mkIf (cfg.enable) (mkMerge [
    (mkIf (pkgs.stdenv.isLinux) (import ./nixos.nix args))
    (mkIf (pkgs.stdenv.isDarwin) (import ./darwin.nix args))

    {
      users.users.todd = {
        shell = pkgs.fish;
      };

      modules.users.todd.home-manager.enable = true;

      modules.users.todd.sops = {
        defaultSopsFile = ./secrets.sops.yaml;
        secrets = {
          atuin_key = {
            path = "${config.home-manager.users.todd.xdg.configHome}/atuin/key";
          };
        };
      };

      modules.users.todd.shell.atuin = {
        enable = true;
        package = pkgs-unstable.atuin;
        sync_address = "https://atuin.greyrock.casa";
        config = {
          key_path = config.home-manager.users.todd.sops.secrets.atuin_key.path;
        };
      };

      modules.users.todd.shell.fish = {
        enable = true;
      };

      modules.users.todd.shell.git = {
        enable = true;
        username = "Todd Punderson";
        email = "agile.car7544@undercovermail.org";
        signing = {
          signByDefault = true;
          key = "B6F2966E0B5ECD11";
        };
        aliases = {
          co = "checkout";
          logo = "log --pretty=format:\"%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ (%cn)\" --decorate";
        };
        config = {
          core = {
            autocrlf = "input";
          };
          init = {
            defaultBranch = "main";
          };
          pull = {
            rebase = true;
          };
          rebase = {
            autoStash = true;
          };
        };
        ignores = [
          # Mac OS X hidden files
          ".DS_Store"
          # Windows files
          "Thumbs.db"
          # asdf
          ".tool-versions"
          # rtx
          ".rtx.toml"
          # Sops
          ".decrypted~*"
          "*.decrypted.*"
          # Python virtualenvs
          ".venv"
        ];
      };

      modules.users.todd.fonts.monaspace.enable = true;

      modules.users.todd.editor.nvim.enable = true;
      modules.users.todd.shell.starship.enable = true;
      modules.users.todd.shell.tmux.enable = true;
    }

    (mkIf (cfg.enableKubernetesTools) (import ./_kubernetes.nix args))
    (mkIf (cfg.enableDevTools) (import ./_devtools.nix args))
  ]);
}
