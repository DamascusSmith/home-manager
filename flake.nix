{
  description = "Home Manager configuration of damascussmith";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

		nixpkgs-old.url = "github:nixos/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

		nixgl = {
			url = "github:nix-community/nixGL";
			inputs.nixpkgs.follows = "nixpkgs";
		};
  };

  outputs =
    { nixpkgs, nixpkgs-old, home-manager, nixgl, ... }:
    let
      system = "x86_64-linux";

			username = builtins.getEnv "USER";
			homeDirectory = builtins.getEnv "HOME";

      pkgs = nixpkgs.legacyPackages.${system};
			oldPkgs = nixpkgs-old.legacyPackages.${system};	
    in
    {
      homeConfigurations."wikkenden-home" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
				extraSpecialArgs = {
					inherit username homeDirectory nixgl oldPkgs;
				};

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ 
					./home.nix
				];
      };
    };
}
