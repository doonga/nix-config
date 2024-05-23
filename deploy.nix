{
  self,
  deploy-rs,
  ...
}:
let
  deployConfig = name: system: cfg: {
    hostname = "${name}.greyrock.io";
    sshOpts = cfg.sshOpts or ["-A"];

    profiles = {
      system = {
        inherit (cfg) sshUser;
        path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.${name};
        user = "root";
      };
    };

    remoteBuild = cfg.remoteBuild or false;
    autoRollback = cfg.autoRollback or false;
    magicRollback = cfg.magicRollback or true;
  };
in
{
  deploy.nodes = {
    nas = deployConfig "nas" "x86_64-linux" {sshUser = "todd"; remoteBuild = true;};
    dns1 = deployConfig "dns1" "x86_64-linux" {sshUser = "todd"; remoteBuild = true;};
  };
  checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
}
