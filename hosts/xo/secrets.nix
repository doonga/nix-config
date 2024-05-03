{
  pkgs,
  config,
  ...
}:
{
  config = {
    environment.systemPackages = [
      pkgs.sops
      pkgs.age
    ];

    sops = {
      defaultSopsFile = ./secrets.sops.yaml;
      age.sshKeyPaths = [
        "/etc/ssh/ssh_host_ed25519_key"
      ];
      secrets = {
        "networking/cloudflare/auth" = {
          owner = config.users.users.acme.name;
        };
      };
    };
  };
}
