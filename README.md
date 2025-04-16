# AWS VPN Client nix flake

*Note! This does not currently work*

A nix flake providing the AWS VPN Client.

Include in your nix flake configuration:

```
{
    inputs = {
        awsvpn.url = "github:tebro/awsvpn-flake";
    };
    
    outputs = {
        nixpkgs,
        awsvpn,
        ...
    }@inputs: {
        nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
                awsvpn.nixosModules.awsvpnclient
                {
                  services.awsvpnclient.enable = true;
                }
            ];
        };
    };
}
```

