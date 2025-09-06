{
  description = "My custom packages";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  
  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in {
          gx52 = pkgs.callPackage ./pkgs/gx52 { };
        });
      
      # NixOS modules
      nixosModules = {
        gx52 = import ./modules/gx52.nix;
        default = self.nixosModules.gx52;
      };

      # Optional: make packages available as overlays
      overlays.default = final: prev: {
        my-packages = self.packages.${final.system};
      };
    };
}