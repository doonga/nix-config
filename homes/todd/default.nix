{
  pkgs,
  hostname,
  flake-packages,
  ...
}:
{
  imports = [
    ../_modules

    ./secrets
    ./hosts/${hostname}.nix
  ];

  modules = {
    editor = {
      nvim = {
        enable = true;
        package = flake-packages.${pkgs.system}.nvim;
        makeDefaultEditor = true;
      };
    };

    security = {
      ssh = {
        enable = true;
        matchBlocks = {
          "gateway.greyrock.io" = {
            port = 22;
            user = "vyos";
          };
          "nas.greyrock.io" = {
            port = 22;
            user = "todd";
            forwardAgent = true;
          };
        };
      };
    };

    shell = {
      fish.enable = true;

      git = {
        enable = true;
        username = "Todd Punderson";
        email = "agile.car7544@undercovermail.org";
        signingKey = "B6F2966E0B5ECD11";
      };

      go-task.enable = true;

      mise = {
        enable = true;
        package = pkgs.unstable.mise;
      };
    };
  };
}
