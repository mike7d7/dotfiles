{
  pkgs,
  inputs,
  lib,
  ...
}:
let
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
in
{
  nixpkgs.overlays = [
    (final: prev: {
      ouch = prev.ouch.override { enableUnfree = true; };
      prismlauncher = prev.prismlauncher.override {
        jdks = with pkgs; [
          graalvmPackages.graalvm-oracle
        ];
      };
    })
  ];
  environment.systemPackages = with pkgs; [
    git
    pipewire
    libreoffice-qt6-fresh
    hunspell
    hunspellDicts.es_MX
    hunspellDicts.en_US
    xwayland-satellite
    htop
    pwvucontrol
    ludusavi
    osu-lazer-bin
    keepassxc
    nvtopPackages.full
    nomacs
    wl-clipboard
    xeyes
    qalculate-qt
    localsend
    heroic
    gnome-themes-extra
    transmission_4-gtk
    prismlauncher
    lazygit
    obs-studio
    ripunzip
    kew
    joplin-desktop
    bluetuith

    wl-mirror
    rsync
    gnupg
    pinentry-tty
    graphite-cursors
    kdePackages.dolphin
    kdePackages.qtsvg
    kdePackages.kio-fuse # to mount remote filesystems via FUSE
    kdePackages.kio-extras # extra protocols support (sftp, fish and more)
    kdePackages.qtstyleplugin-kvantum
    libsForQt5.qtstyleplugin-kvantum

    waypaper
    ripdrag
    jftui
    ouch
    trash-cli
    solaar # fixes bug with wireless logitech keyboard
    (pkgs.epsonscan2.override { withNonFreePlugins = true; })
    discord
    reaper
    python3
    matugen
    halloy
    inputs.nix-matlab.packages.x86_64-linux.matlab
    aisleriot
    dgop
    typst
    wineWow64Packages.yabridge # needed for AMS2 mods
    winetricks
    rstudio
    inputs.handy.packages.x86_64-linux.default
    rpcs3-latest

    firefox-sync
  ];
  systemd.user.services.firefox-profile-memory-cache = {
    description = "Firefox profile memory cache";
    wantedBy = [ "default.target" ];
    path = [ pkgs.rsync ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${firefox-sync}/bin/firefox-sync 0shu6evv.default";
      ExecStop = "${firefox-sync}/bin/firefox-sync 0shu6evv.default";
    };
  };
}
