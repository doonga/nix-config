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
  ];

  config = {
    networking = {
      hostName = hostname;
      hostId = "007f0200";
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
          "samba-users"
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
        k3s = {
          enable = true;
          package = pkgs.unstable.k3s_1_29;
          extraFlags = [
            "--tls-san=${config.networking.hostName}.greyrock.io"
            "--tls-san=omni.k8s.greyrock.io"
          ];
        };

        openssh.enable = true;

        smartd.enable = true;
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
