{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/d12574353329291e661805312544b1c68c13911e.tar.gz") {}
}:

pkgs.mkShell {
  buildInputs = [
    pkgs.elmPackages.elm
    pkgs.elmPackages.elm-test
    pkgs.elmPackages.elm-format
    pkgs.nodejs
  ];
}
