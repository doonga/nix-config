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
        "networking/bind/rndc-key" = {
          restartUnits = [ "bind.service" ];
          owner = config.users.users.named.name;
        };
        "networking/bind/dns1-dns2-key" = {
          restartUnits = [ "bind.service" ];
          owner = config.users.users.named.name;
        };
      };
    };
  };
}
