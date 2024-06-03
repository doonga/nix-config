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
        "storage/minio/root-credentials" = {
          owner = config.users.users.minio.name;
          restartUnits = [ "minio.service" ];
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
