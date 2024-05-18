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
    package = lib.mkPackageOption pkgs "meshcentral" { };
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
            proxyPass = "http://127.0.0.1:4430/";
            proxyWebsockets = true;
            extraConfig =
              "proxy_ssl_verify off;"
              ;
          };
        };
      };
      streamConfig = ''
        ssl_certificate /var/lib/acme/meshcentral.greyrock.casa/fullchain.pem;
        ssl_certificate_key /var/lib/acme/meshcentral.greyrock.casa/key.pem;
        ssl_session_cache shared:MPSSSL:10m;
        ssl_ciphers HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers on;

        server {
          listen 4433 ssl;
          proxy_pass 127.0.0.1:44330;
          proxy_next_upstream on;
        }
      '';
    };

    systemd.services.meshcentral = {
      environment = {
        NODE_ENV = "production";
      };
    };

    services.meshcentral = {
      enable = true;
      inherit (cfg) package;
      settings = {
        settings = {
          cert = "meshcentral.greyrock.casa";
          port = 4430;
          aliasport = 443;
          redirport = 800;
          agentpong = 300;
          tlsoffload = "127.0.0.1";
          mpsport = "44330";
          mpsaliasport = "4433";
          mpstlsoffload = "true";
          webrtc = "true";
        };
        domains = {
          "" = {
            certUrl = "https://meshcentral.greyrock.casa/";
          };
        };
        smtp = {
          host = "smtp.greyrock.casa";
          port = 25;
          from = "meshcentral@m.greyrock.io";
        };
      };
    };
  };
}
