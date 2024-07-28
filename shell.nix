{ pkgs ? import <nixpkgs> {} }:

with pkgs;
let 
in mkShell {
  buildInputs = [
    git
    curl
    wget
    age
    sops
    nixfmt
    go
    gitleaks
    pre-commit
    python310
    python310Packages.pre-commit-hooks
  ];
}