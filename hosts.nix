let
  hasSuffix = suffix: content:
    let
      inherit (builtins) stringLength substring;
      lenContent = stringLength content;
      lenSuffix = stringLength suffix;
    in
    lenContent >= lenSuffix
    && substring (lenContent - lenSuffix) lenContent content == suffix
  ;

  mkHost =
    { type
    , hostPlatform
    , address ? null
    , pubkey ? null
    , homeDirectory ? null
    , remoteBuild ? true
    , large ? false
    }:
    if type == "nixos" then
      assert address != null && pubkey != null;
      assert (hasSuffix "linux" hostPlatform);
      {
        inherit type hostPlatform address pubkey remoteBuild large;
      }
    else if type == "darwin" then
      assert pubkey != null;
      assert (hasSuffix "darwin" hostPlatform);
      {
        inherit type hostPlatform pubkey large;
      }
    else if type == "home-manager" then
      assert homeDirectory != null;
      {
        inherit type hostPlatform homeDirectory large;
      }
    else throw "unknown host type '${type}'";
in
{
  todds-macbook = mkHost {
    type = "darwin";
    hostPlatform = "aarch64-darwin";
    pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILt+39KiHG0k5C4u/r+SZp14QZjzJGYwMxh+swzjZUEW";
  };
  nas = mkHost {
    type = "nixos";
    address = "nas.greyrock.io";
    hostPlatform = "x86_64-linux";
    pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK68d804gooujHV8JUwkq1lDu2In6Ej0pQq5eNqvU3ae";
    remoteBuild = true;
  };
}
