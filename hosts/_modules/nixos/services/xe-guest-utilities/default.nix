{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.modules.services.xe-guest-utilities;
in
{
  options.modules.services.xe-guest-utilities = {
    enable = lib.mkEnableOption "xe-guest-utilities";
    package = lib.mkPackageOption pkgs "xe-guest-utilities" { };
  };

  config = lib.mkIf cfg.enable {
    services.xe-guest-utilities = {
      enable = true;
    };

    environment.systemPackages = [ cfg.package ];
  };
}
