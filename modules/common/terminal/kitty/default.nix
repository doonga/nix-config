{ username }: {pkgs,lib, config, ... }:
with lib;

let
  cfg = config.modules.users.${username}.terminal.kitty;

in {
  options.modules.users.${username}.terminal.kitty = {
    enable = mkEnableOption "${username} kitty";
  };

  config = mkIf cfg.enable {
    home-manager.users.${username} = {
      programs.kitty = {
        enable = true;
        font = {
          name = "FiraCode Nerd Font";
          size = 16;
        };
        settings = {
          confirm_os_window_close = 0;
        };
        shellIntegration.enableFishIntegration = true;
        theme = "Catppuccin-Macchiato";
      };
    };
  };
}
