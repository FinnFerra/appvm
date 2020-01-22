# { stdenv
# , lib
# , buildGoPackage
# , fetchgit
# , nix
# , virt-viewer
# , makeWrapper
# }:
let
  pkgs = import <nixpkgs> {};
  virt-manager-without-menu = pkgs.virt-viewer.overrideAttrs(x: {
    patches = [ ./patches/0001-Remove-menu-bar.patch ];
  });
in with pkgs;

buildGoPackage rec {
  pname = "appvm";
  #version = "0.3";
  version = "master";

  buildInputs = [ makeWrapper ];

  goPackagePath = "code.dumpstack.io/tools/${pname}";

  # src = fetchgit {
  #   rev = "refs/tags/v${version}";
  #   url = "https://code.dumpstack.io/tools/${pname}.git";
  #   sha256 = "1ji4g868xrv6kx6brdrqfv0ca12vjw0mcndffnnwpczh4yv81sd3";
  src = builtins.fetchGit {
    url = "https://code.dumpstack.io/tools/appvm.git";
    ref = "master";
  };

  goDeps = ./deps.nix;

  postFixup = ''
    wrapProgram $bin/bin/appvm \
      --prefix PATH : "${lib.makeBinPath [ nix virt-manager-without-menu ]}"
  '';

  meta = {
    description = "Nix-based app VMs";
    homepage = "https://code.dumpstack.io/tools/${pname}";
    maintainers = [ lib.maintainers.dump_stack ];
    license = lib.licenses.gpl3;
  };
}
