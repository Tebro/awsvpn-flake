{
  description = "NixOS configuration with AWS VPN Client";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };

        awsvpnclient = pkgs.callPackage ./awsvpnclient.nix {};
      in {
        packages = {
          inherit awsvpnclient;
          default = awsvpnclient;
        };
      }
    )
    // {
      nixosModules.awsvpnclient = {
        config,
        lib,
        pkgs,
        ...
      }: let
        cfg = config.services.awsvpnclient;
      in {
        options.services.awsvpnclient = {
          enable = lib.mkEnableOption "AWS VPN Client service";
        };

        config = lib.mkIf cfg.enable {
          environment.systemPackages = [self.packages.${pkgs.system}.awsvpnclient];

          systemd.services.awsvpnclient = {
            description = "AWS VPN Client Service";
            after = ["network.target"];
            wantedBy = ["multi-user.target"];
            serviceConfig = {
              Type = "simple";
              ExecStart = "${self.packages.${pkgs.system}.awsvpnclient}/opt/awsvpnclient/Service/ACVC.GTK.Service";
              Restart = "always";
              RestartSec = "1s";
              User = "root";
            };
          };
        };
      };
    };
}
