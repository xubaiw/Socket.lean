{
  description = "Socket lib for Lean";

  inputs = {
    lean = {
      url = github:yatima-inc/lean4/acs/add-nix-ability-for-native-libs;
    };
    utils = {
      url = github:yatima-inc/nix-utils;
    };

    nixpkgs.url = github:nixos/nixpkgs/nixos-21.05;
    flake-utils = {
      url = github:numtide/flake-utils;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, lean, flake-utils, nixpkgs, utils }:
    let
      supportedSystems = [
        # "aarch64-linux"
        # "aarch64-darwin"
        "i686-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
    in
    flake-utils.lib.eachSystem supportedSystems (system:
      let
        leanPkgs = lean.packages.${system};
        pkgs = import nixpkgs { inherit system; };
        name = "lean-socket";
        inherit (utils.lib.${system}) buildCLib forEachRowJoin;
        native = buildCLib {
          src = ./native;
          name = "lean-socket-native";
          updateCCOptions = o: o ++ [ "-I${leanPkgs.lean-bin-tools-unwrapped}/include" ];
          extraDrvArgs = { linkName = "lean-socket-native"; };
        };
        project = leanPkgs.buildLeanPackage {
          name = "Socket";
          src = ./.;
          nativeSharedLibs = [ native.sharedLib ];
        };
        examples = import ./examples/default.nix {
          inherit pkgs native;
          lean = leanPkgs;
          Socket = project;
        };
      in
      {
        inherit project;
        packages = {
          inherit native;
          inherit (project) modRoot sharedLib staticLib;
          inherit examples;
        };

        checks =
          let
            exampleExecutables = forEachRowJoin (name: p: { ${name} = p.executable; }) examples;
          in
          {
            inherit exampleExecutables;
          };

        defaultPackage = project.modRoot;
        devShell = pkgs.mkShell {
          buildInputs = [ leanPkgs.lean ];
          LEAN_PATH = "${leanPkgs.Lean.modRoot}";
          CPATH = "${leanPkgs.Lean.modRoot}";
        };
      });
}
