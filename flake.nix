{
  description = "imrsz: a simple image resizing tool";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "nixpkgs/nixos-22.05";

  outputs = { self, nixpkgs }:
    let
      version = "0.1.0";
      supportedSystems =
        [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

    in {
      packages = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in {
          imrsz = pkgs.buildGoModule {
            pname = "imrsz";
            inherit version;
            src = ./.;

            vendorSha256 =
              "sha256-2cuSHjD9e9s0/Z02sRbjlnfa0ehVMhJ8RohFSZvjgSQ=";

            proxyVendor = true;
          };

          devShell =
            pkgs.mkShell { buildInputs = with pkgs; [ gopls go-tools ]; };
        });

      defaultPackage = forAllSystems (system: self.packages.${system}.imrsz);
    };
}
