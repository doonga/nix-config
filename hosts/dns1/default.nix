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
        bind = {
          enable = true;
          config = import ./config/bind.nix {inherit config;};
        };

        blocky = {
          enable = true;
          package = pkgs.unstable.blocky;
          config = import ./config/blocky.nix;
        };

        cfdyndns = {
          enable = true;
          apiTokenFile = config.sops.secrets."networking/cloudflare/ddns/apiToken".path;
          recordsFile = config.sops.secrets."networking/cloudflare/ddns/records".path;
        };

        dnsdist = {
          enable = true;
          config = builtins.readFile ./config/dnsdist.conf;
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
