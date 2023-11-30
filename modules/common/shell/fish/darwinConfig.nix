{ pkgs, ... }:
{
  programs.fish = {
    functions = {
      nixswitch = "darwin-rebuild switch --flake ~/src/nix-config";
    };
  };
}
