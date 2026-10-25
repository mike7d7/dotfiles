{
  pkgs,
  inputs,
  lib,
  ...
}: let
  custom-packages = import ./packages-custom.nix {inherit pkgs lib;};
in {
  nixpkgs.overlays = [
    (final: prev: {
      ouch = prev.ouch.override {enableUnfree = true;};
      kickoff = prev.kickoff.overrideAttrs (prev: rec {
        version = "unstable-2026-10-24";

        src = pkgs.fetchFromGitHub {
          owner = "mike7d7";
          repo = "kickoff";
          rev = "1b519bf015bf4f420f325ccc8a82b060c09e6c10";
          hash = "sha256-JlUrdOdggSJaCsU84QCtM9c9fs/nPUGsIl4WF2RVETA=";
        };
        cargoDeps = pkgs.rustPlatform.importCargoLock {
          lockFile = "${src}/Cargo.lock";
        };
      });
      digital =
        prev.digital.overrideAttrs
        (prev: {
          version = "unstable-2026-09-25";

          src = pkgs.fetchFromGitHub {
            owner = "hneemann";
            repo = "Digital";
            rev = "1e5d730597897704cc47b0219f908d5b201828b3";
            hash = "sha256-XSYBHfS5YfhE8itPwv3MrsJzK2o+ZL0fjkfTZIYLEK0=";
          };
        });

      prismlauncher = prev.prismlauncher.override {
        jdks = with pkgs; [
          graalvmPackages.graalvm-oracle
        ];
      };
    })
  ];
  environment.systemPackages = with pkgs;
    [
      git
      pipewire
      libreoffice-stable
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
      kdePackages.kio # needed since 25.11
      kdePackages.kio-fuse # to mount remote filesystems via FUSE
      kdePackages.kio-extras # extra protocols support (sftp, fish and more)
      kdePackages.qtstyleplugin-kvantum
      libsForQt5.qtstyleplugin-kvantum

      jftui
      ouch
      trash-cli
      solaar # fixes bug with wireless logitech keyboard
      (pkgs.epsonscan2.override {withNonFreePlugins = true;})
      discord
      python3
      matugen
      halloy
      inputs.custom-rstudio.packages.x86_64-linux.default
      handy
      dux-gop
      dux-calendar
      quickshell
      typst
      wineWow64Packages.yabridge # needed for AMS2 mods
      winetricks
      rclone
      restic
      # rpcs3

      winboat
      digital
      xorg-server
      openbox

      ashell
      kickoff
      playerctl
      swaylock
      inputs.sweetbg.packages.x86_64-linux.sweetbg
      inputs.matuwall.packages.x86_64-linux.matuwall
      inputs.kickoff-dot.packages.x86_64-linux.default
    ]
    ++ custom-packages.packages;
  systemd.user.services.firefox-profile-memory-cache = {
    description = "Firefox profile memory cache";
    wantedBy = ["default.target"];
    path = [pkgs.rsync];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${custom-packages.firefox-sync}/bin/firefox-sync 0shu6evv.default";
      ExecStop = "${custom-packages.firefox-sync}/bin/firefox-sync 0shu6evv.default";
    };
  };
}
