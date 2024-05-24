{
  pkgs,
  lib,
  hostname,
  ...
}:
{
  config = {
    networking = {
      computerName = "Todd's MacBook Pro";
      hostName = hostname;
      localHostName = hostname;
    };

    users.users.todd = {
      name = "todd";
      home = "/Users/todd";
      shell = pkgs.fish;
      openssh.authorizedKeys.keys = lib.strings.splitString "\n" (builtins.readFile ../../homes/todd/config/ssh/ssh.pub);
    };

    system.activationScripts.postActivation.text = ''
      # Must match what is in /etc/shells
      sudo chsh -s /run/current-system/sw/bin/fish todd
    '';

    homebrew = {
      taps = [
      ];
      brews = [
      ];
      casks = [
        "discord"
        "google-chrome"
        "obsidian"
        "orbstack"
        "plex"
        "tableplus"
        "transmit"
      ];
      masApps = {
        "Keka" = 470158793;
        "Passepartout" = 1433648537;
      };
    };
  };
}
