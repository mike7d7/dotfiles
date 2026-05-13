{
  pkgs,
  inputs,
  lib,
  ...
}:
let
  custom-packages = import ./packages-custom.nix { inherit pkgs lib; };
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
  environment.systemPackages =
    with pkgs;
    [
      git
      pipewire
      libreoffice-fresh
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
      inputs.handy.packages.x86_64-linux.default
      aisleriot
      dgop
      typst
      wineWow64Packages.yabridge # needed for AMS2 mods
      winetricks
      rclone
      restic
      stirling-pdf-desktop
      rpcs3
      starsector
    ]
    ++ custom-packages.packages;
  systemd.user.services.firefox-profile-memory-cache = {
    description = "Firefox profile memory cache";
    wantedBy = [ "default.target" ];
    path = [ pkgs.rsync ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${custom-packages.firefox-sync}/bin/firefox-sync 0shu6evv.default";
      ExecStop = "${custom-packages.firefox-sync}/bin/firefox-sync 0shu6evv.default";
    };
  };
}
