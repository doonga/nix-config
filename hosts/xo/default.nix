{
  pkgs,
  lib,
  config,
  hostname,
  ...
}:
let
  ifGroupsExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  imports = [
    ./hardware-configuration.nix
    ./secrets.nix
  ];

  config = {
    networking = {
      hostName = hostname;
      hostId = "8425e349";
      useDHCP = true;
      firewall.enable = false;
    };

    users.users.todd = {
      uid = 1000;
      name = "todd";
      home = "/home/todd";
      group = "todd";
      shell = pkgs.fish;
      openssh.authorizedKeys.keys = lib.strings.splitString "\n" (builtins.readFile ../../homes/todd/config/ssh/ssh.pub);
      isNormalUser = true;
      extraGroups =
        [
          "wheel"
          "users"
        ]
        ++ ifGroupsExist [
          "network"
        ];
    };
    users.groups.todd = {
      gid = 1000;
    };

    system.activationScripts.postActivation.text = ''
      # Must match what is in /etc/shells
      chsh -s /run/current-system/sw/bin/fish todd
    '';

    modules = {
      services = {
        chrony = {
          enable = true;
          servers = [
            "time1.greyrock.io"
            "time2.greyrock.io"
            "time3.greyrock.io"
            "time4.greyrock.io"
          ];
        };

        nginx = {
          enableAcme = true;
          acmeCloudflareAuthFile = config.sops.secrets."networking/cloudflare/auth".path;
        };

        node-exporter.enable = true;

        xen-orchestra = {
          enable = true;
          enableReverseProxy = true;
          xen-orchestraURL = "xo.greyrock.io";
        };

        openssh.enable = true;
      };

      users = {
        groups = {
          admins = {
            gid = 991;
            members = [
              "todd"
            ];
          };
        };
      };
    };

    # Use the systemd-boot EFI boot loader.
    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };
}
