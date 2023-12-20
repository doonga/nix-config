{ pkgs, ...}:
{
  nix.gc.interval = {
    Weekday = 0;
    Hour = 2;
    Minute = 0;
  };

  services.nix-daemon.enable = true;

  # Use touch ID for sudo auth
  security.pam.enableSudoTouchIdAuth = true;

  system.stateVersion = 4;

  fonts.fontDir.enable = true;
  fonts.fonts = with pkgs; [
    font-awesome
    (nerdfonts.override {fonts = ["FiraCode"];})
  ];

  system.defaults = {
    finder.AppleShowAllExtensions = true;
    finder._FXShowPosixPathInTitle = true;
    NSGlobalDomain.AppleShowAllExtensions = true;
    NSGlobalDomain.InitialKeyRepeat = 14;
    NSGlobalDomain.KeyRepeat = 1;
  };

  environment = {
    systemPath = ["/opt/homebrew/bin"];
  };

  homebrew = {
    enable = true;
    onActivation.cleanup = "uninstall";
    caskArgs.no_quarantine = true;
    global.brewfile = true;
    masApps = {
      "1Blocker - Ad Blocker" = 1365531024;
      "1Password for Safari" = 1569813296;
      "CARROT Weather" = 993487541;
    };
    casks = [
      "1password"
      "1password-cli"
      "balenaetcher"
      "bartender"
      "beyond-compare"
      "eloston-chromium"
      "gpg-suite-no-mail"
      "iterm2"
      "mqtt-explorer"
      "orbstack"
      "rocket"
      "shottr"
      "yubico-yubikey-manager"
    ];
    taps = [];
    brews = [
      "mas"
      "watch"
    ];
  };

}
