{
  description = "My flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    playlist-select.url = "github:isaacemilien/playlist-select";
    tiny-terminal-timer.url = "github:isaacemilien/tiny-terminal-timer";
  };

  outputs = {self, nixpkgs, home-manager, playlist-select, tiny-terminal-timer, ...}:
  let
    lib = nixpkgs.lib;
  in {
    nixosConfigurations = {
      nixos = lib.nixosSystem {
	system = "x86_64-linux";
	modules = [
	  ./configuration.nix
	  home-manager.nixosModules.home-manager
	  {
	    home-manager.useGlobalPkgs = true;
	    home-manager.useUserPackages = true;
	    home-manager.users.alice = import ./home/alice/home.nix;
	  }
	  ({ pkgs, ... }: {
            environment.systemPackages = [ 
              playlist-select.packages.x86_64-linux.default
              tiny-terminal-timer.packages.x86_64-linux.default
            ];
          })
	];
      };
      ec2 = lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/ec2.nix
        ];
      };
    };
  };
}
