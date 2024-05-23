{
  pkgs,
  config,
  ...
}:
{
  config = {
    sops = {
      defaultSopsFile = ./secrets.sops.yaml;
      secrets = {
        onepassword-credentials = {
          mode = "0444";
        };
        "networking/cloudflare/ddns/apiToken" = {};
        "networking/cloudflare/ddns/records" = {};
        "networking/bind/rndc-key" = {
          restartUnits = [ "bind.service" ];
          owner = config.users.users.named.name;
        };
        "networking/bind/externaldns-key" = {
          restartUnits = [ "bind.service" ];
          owner = config.users.users.named.name;
        };
        "networking/bind/zones/greyrock.casa" = {
          restartUnits = [ "bind.service" ];
          owner = config.users.users.named.name;
        };
        "networking/cloudflare/auth" = {
          owner = config.users.users.acme.name;
        };
      };
    };
  };
}
