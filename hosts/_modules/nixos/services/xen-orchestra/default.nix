{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.modules.services.xen-orchestra;
in
{
  options.modules.services.xen-orchestra = {
    enable = lib.mkEnableOption "xen-orchestra";
    xo-dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/xen-orchestra/xo-data";
    };
    redis-dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/xen-orchestra/redis-data";
    };
    enableReverseProxy = lib.mkEnableOption "xen-orchestra-reverseProxy";
    xen-orchestraURL = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
  };

  config = lib.mkIf cfg.enable {
    modules.services.nginx = lib.mkIf cfg.enableReverseProxy {
      enable = true;
      virtualHosts = {
        "${cfg.xen-orchestraURL}" = {
          enableACME = config.modules.services.nginx.enableAcme;
          acmeRoot = null;
          forceSSL = config.modules.services.nginx.enableAcme;
          locations."/" = {
            proxyPass = "http://127.0.0.1:8080/";
            proxyWebsockets = true;
          };
        };
      };
    };

    modules.services.podman.enable = true;
    system.activationScripts.makeXenOrchestraDataDirs = lib.stringAfter [ "var" ] ''
      mkdir -p "${cfg.xo-dataDir}"
      mkdir -p "${cfg.redis-dataDir}"
    '';

    virtualisation.oci-containers.containers = {
      xen-orchestra = {
        image = "docker.io/ronivay/xen-orchestra:5.142.1";
        autoStart = true;
        ports = [ "127.0.0.1:8080:8080" ];
        volumes = [
          "${cfg.xo-dataDir}:/var/lib/xo-server"
          "${cfg.redis-dataDir}:/var/lib/redis"
        ];
        environment = {
          HTTP_PORT = "8080";
        };
        extraOptions = [
          "--cap-add=SYS_ADMIN"
          "--cap-add=DAC_READ_SEARCH"
          "--stop-timeout=60"
        ];
      };
    };
  };
}
