{ pkgs, pkgs-unstable, ... }:
let
  vscode-extensions = (import ../../editor/vscode/extensions.nix){pkgs = pkgs;};
in
{
  modules.users.todd.kubernetes.k9s = {
    enable = true;
    package = pkgs-unstable.k9s;
    config = {
      k9s = {
        ui = {
          skin = "catppuccin-macchiato";
        };
      };
    };
  };
  modules.users.todd.kubernetes.krew.enable = true;
  modules.users.todd.kubernetes.kubecm = {
    enable = true;
    package = pkgs-unstable.kubecm;
  };
  modules.users.todd.kubernetes.stern.enable = true;

  modules.users.todd.shell.fish = {
    config.programs.fish = {
      shellAliases = {
        k = "kubectl";
      };
      interactiveShellInit = ''
        flux completion fish | source
      '';
    };
  };

  modules.users.todd.editor.vscode = {
    extensions = with vscode-extensions; [
      ms-kubernetes-tools.vscode-kubernetes-tools
    ];

    config = {
      vs-kubernetes = {
        "vs-kubernetes.crd-code-completion" = "disabled";
      };
    };
  };
}
