{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.modules.services.qemu-guest;
in
{
  options.modules.services.qemu-guest = {
    enable = lib.mkEnableOption "qemu-guest";
    exports = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
  };

  config = lib.mkIf cfg.enable {
    services.udev.extraRules = ''
      SUBSYSTEM=="virtio-ports", ATTR{name}=="org.qemu.guest_agent.0", TAG+="systemd" ENV{SYSTEMD_WANTS}="qemu-guest-agent.service"
    '';

    systemd.services.qemu-guest-agent = {
      description = "Run the QEMU Guest Agent";
      serviceConfig = {
        ExecStart = "${pkgs.qemu.ga}/bin/qemu-ga";
        Restart = "always";
        RestartSec = 0;
      };
    };
  };
}
