{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.modules.services.meshcentral;
in
{
  options.modules.services.meshcentral = {
    enable = lib.mkEnableOption "meshcentral";
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/meshcentral/data";
    };
    userDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/meshcentral/user";
    };
    enableReverseProxy = lib.mkEnableOption "meshcentral-reverseProxy";
    meshcentralURL = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
  };

  config = lib.mkIf cfg.enable {
    modules.services.nginx = lib.mkIf cfg.enableReverseProxy {
      enable = true;
      virtualHosts = {
        "${cfg.meshcentralURL}" = {
          enableACME = config.modules.services.nginx.enableAcme;
          acmeRoot = null;
          forceSSL = config.modules.services.nginx.enableAcme;
          locations."/" = {
            proxyPass = "https://127.0.0.1:8085/";
            proxyWebsockets = true;
            extraConfig =
              "proxy_ssl_verify off;"
              ;
          };
        };
      };
    };

    modules.services.podman.enable = true;
    system.activationScripts.makeOnePasswordConnectDataDir = lib.stringAfter [ "var" ] ''
      mkdir -p "${cfg.dataDir}"
      chown -R 1000:1000 ${cfg.dataDir}
      mkdir -p "${cfg.userDir}"
      chown -R 1000:1000 ${cfg.userDir}
    '';

    virtualisation.oci-containers.containers = {
      meshcentral = {
        image = "typhonragewind/meshcentral:1.1.22";
        autoStart = true;
        ports = [ "8085:443" ];
        environment = {
          HOSTNAME = "meshcentral.greyrock.casa";
          REVERSE_PROXY = "meshcentral.greyrock.casa";
          REVERSE_PROXY_TLS_PORT = "443";
          IFRAME = "false";
          ALLOW_NEW_ACCOUNTS = "true";
          WEBRTC = "true";
        };
        volumes = [
          "${cfg.dataDir}:/opt/meshcentral/meshcentral-data"
          "${cfg.userDir}:/opt/meshcentral/meshcentral-files"
        ];
      };
    };
  };
}
