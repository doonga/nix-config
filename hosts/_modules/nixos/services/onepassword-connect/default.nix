{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.modules.services.onepassword-connect;
in
{
  options.modules.services.onepassword-connect = {
    enable = lib.mkEnableOption "onepassword-connect";
    credentialsFile = lib.mkOption {
      type = lib.types.path;
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/onepassword-connect/data";
    };
    enableReverseProxy = lib.mkEnableOption "onepassword-connect-reverseProxy";
    onepassword-connectURL = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
  };

  config = lib.mkIf cfg.enable {
    modules.services.nginx = lib.mkIf cfg.enableReverseProxy {
      enable = true;
      virtualHosts = {
        "${cfg.onepassword-connectURL}" = {
          enableACME = config.modules.services.nginx.enableAcme;
          acmeRoot = null;
          forceSSL = config.modules.services.nginx.enableAcme;
          locations."/" = {
            proxyPass = "http://127.0.0.1:8080/";
          };
        };
      };
    };

    modules.services.podman.enable = true;
    system.activationScripts.makeOnePasswordConnectDataDir = lib.stringAfter [ "var" ] ''
      mkdir -p "${cfg.dataDir}"
      chown -R 999:999 ${cfg.dataDir}
    '';

    virtualisation.oci-containers.containers = {
      onepassword-connect-api = {
        image = "docker.io/1password/connect-api:1.7.2";
        autoStart = true;
        ports = [ "127.0.0.1:8080:8080" ];
        volumes = [
          "${cfg.credentialsFile}:/home/opuser/.op/1password-credentials.json"
          "${cfg.dataDir}:/home/opuser/.op/data"
        ];
      };

      onepassword-connect-sync = {
        image = "docker.io/1password/connect-sync:1.7.2";
        autoStart = true;
        ports = [ "127.0.0.1:8081:8080" ];
        volumes = [
          "${cfg.credentialsFile}:/home/opuser/.op/1password-credentials.json"
          "${cfg.dataDir}:/home/opuser/.op/data"
        ];
      };
    };
  };
}
