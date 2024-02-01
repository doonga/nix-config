{ hostName, pkgs, ... }:
{
  imports = [
    ./device.nix

    ./users
    ./users/todd
    ./users/andy
  ];

  networking.hostName = hostName;

  time.timeZone = "America/New_York";

  nix = {
    settings = {
      accept-flake-config = true;
      builders-use-substitutes = true;
      cores = 0;
      experimental-features = [ "nix-command" "flakes" ];
      max-jobs = "auto";
      substituters = [
        "https://greyrock.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "greyrock.cachix.org-1:0CVPQyIzNXZEIvN+b7ATQZONUhl6aKyVIHITNikG9PE="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      warn-dirty = false;
    };
    gc = {
      automatic = true;
      # Delete older generations too
      options = "--delete-older-than 2d";
    };
  };

  environment.systemPackages = with pkgs; [
    gnused
    gnugrep
  ];
}
