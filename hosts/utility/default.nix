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
      hashedPasswordFile = config.sops.secrets."users/todd/password".path;
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

        meshcentral = {
          enable = true;
          enableReverseProxy = true;
          package = pkgs.unstable.meshcentral;
          meshcentralURL = "meshcentral.greyrock.casa";
        };

        nginx = {
          enableAcme = true;
          acmeCloudflareAuthFile = config.sops.secrets."networking/cloudflare/auth".path;
        };

        node-exporter.enable = true;

        onepassword-connect = {
          enable = true;
          credentialsFile = config.sops.secrets.onepassword-credentials.path;
          enableReverseProxy = true;
          onepassword-connectURL = "onepassword-connect.greyrock.casa";
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
