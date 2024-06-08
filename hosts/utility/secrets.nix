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
        "networking/cloudflare/auth" = {
          owner = config.users.users.acme.name;
        };
        "users/todd/password" = {
          neededForUsers = true;
        };
      };
    };
  };
}
