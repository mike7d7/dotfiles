{ pkgs, lib }:

let
  backup-script = pkgs.writeShellScriptBin "backup-script" ''
    restic -r rclone:o-pi:Restic backup /home/mig/Documents /home/mig/Games/Savefiles --skip-if-unchanged
  '';
  firefox-sync = pkgs.writeShellScriptBin "firefox-sync" ''
    static=static-$1
    link=$1
    volatile=/dev/shm/firefox-$1-$USER

    IFS=
    set -efu

    cd ~/.mozilla/firefox

    if [ ! -r $volatile ]; then
    	mkdir -m0700 $volatile
    fi

    if [ "$(readlink $link)" != "$volatile" ]; then
     mv $link $static
     ln -s $volatile $link
    fi

    if [ -e $link/.unpacked ]; then
     rsync -av --delete --exclude .unpacked ./$link/ ./$static/
    else
     rsync -av ./$static/ ./$link/
     touch $link/.unpacked
    fi
  '';
  rpcs3-latest = pkgs.rpcs3.overrideAttrs (old: {
    NIX_CFLAGS_COMPILE = toString (old.NIX_CFLAGS_COMPILE or "") + " -march=x86-64-v3 -O3";

    version = "0.0.40";
    src = pkgs.fetchFromGitHub {
      owner = "RPCS3";
      repo = "rpcs3";
      rev = "e6cf05cfb73e156818685495814b0b7b8edaa97b";
      postCheckout = ''
        cd $out/3rdparty
        git submodule update --init \
          fusion/fusion asmjit/asmjit yaml-cpp/yaml-cpp SoundTouch/soundtouch stblib/stb \
          feralinteractive/feralinteractive
      '';
      hash = "sha256-KrWsiDQcdbBBDQlui9bXWsxit/fiv7mQoJA2VQlu9fU=";
    };
    buildInputs = old.buildInputs ++ [
      pkgs.protobuf
      pkgs.llvm
    ];
    cmakeFlags = old.cmakeFlags ++ [
      (lib.cmakeBool "USE_SYSTEM_PROTOBUF" true)
      (lib.cmakeBool "USE_SYSTEM_FLATBUFFERS" false)

    ];
  });
  RStudio-with-my-packages = pkgs.rstudioWrapper.override {
    packages = with pkgs.rPackages; [
      ggplot2
      dplyr
      dslabs
      base64enc
      digest
      evaluate
      highr
      htmltools
      jsonlite
      knitr
      mime
      rmarkdown
      stringi
      stringr
      xfun
      yaml
      ggrepel
      ggthemes
      gridExtra
      Biostrings
    ];
  };
in
{
  packages = [
    RStudio-with-my-packages
    pkgs.texlive.combined.scheme-full
    rpcs3-latest
    backup-script
    firefox-sync
  ];
  inherit firefox-sync;
}
