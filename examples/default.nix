{
  # Nixpkgs
  pkgs,
  # The lean packages
  lean,
  # The Socket lean module output from buildLeanPackage
  Socket,
  # The native library
  native,
}:
{
  gethostname = lean.buildLeanPackage {
    src = ./gethostname;
    name = "Main";
    deps = [ Socket ];
    nativeSharedLibs = [ native.sharedLib ];
  };
  http-client = lean.buildLeanPackage {
    src = ./http-client;
    name = "Main";
    deps = [ Socket ];
    nativeSharedLibs = [ native.sharedLib ];
  };
  http-server = lean.buildLeanPackage {
    src = ./http-server;
    name = "Main";
    deps = [ Socket ];
    nativeSharedLibs = [ native.sharedLib ];
  };
  sockaddr = lean.buildLeanPackage {
    src = ./sockaddr;
    name = "Main";
    deps = [ Socket ];
    nativeSharedLibs = [ native.sharedLib ];
  };
}
