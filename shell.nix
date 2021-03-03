{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/f6b5bfdb470d60a876992749d0d708ed7b6b56ca.tar.gz") {}
}:

pkgs.mkShell {
  buildInputs = [
    pkgs.elmPackages.elm
    pkgs.elmPackages.elm-test
    pkgs.elmPackages.elm-format
    pkgs.nodejs
  ];
}
