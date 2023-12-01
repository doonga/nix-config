{ username }: {pkgs, pkgs-unstable, lib, config, ... }:
with lib;

let
  cfg = config.modules.users.${username}.security._1password;

in {
  options.modules.users.${username}.security._1password = {
    enable = mkEnableOption "${username} _1password";
    package = mkPackageOption pkgs-unstable "_1password-gui" { };
  };

  config = mkIf cfg.enable {
    home-manager.users.${username} = {
      home.packages = [ cfg.package ];
    };
  };
}
