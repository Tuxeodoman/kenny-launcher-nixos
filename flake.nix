{
  description = "Kenny Launcher for NixOS";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfreePredicate = pkg: nixpkgs.lib.getName pkg == "kenny-launcher";
      };
      launcher = pkgs.callPackage ./kenny-launcher.nix { };
    in {
      packages.${system} = {
        default = launcher;
        kenny-launcher = launcher;
      };
      apps.${system}.default = {
        type = "app";
        program = "${launcher}/bin/kenny-launcher";
        meta.description = "Kenny Launcher";
      };
      overlays.default = final: prev: {
        kenny-launcher = final.callPackage ./kenny-launcher.nix { };
      };
    };
}
