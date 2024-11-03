{ config, pkgs, lib, ... }:
let
  dock-script = pkgs.writeShellScriptBin "dock-sh" ''
    niri msg output eDP-1 off
    niri msg output DP-1 vrr on
  '';
  undock-script = pkgs.writeShellScriptBin "undock-sh" ''
   niri msg output eDP-1 on
   niri msg output eDP-1 vrr on
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
  aagl = import (builtins.fetchTarball "https://github.com/ezKEa/aagl-gtk-on-nix/archive/main.tar.gz");
  navicat = pkgs.callPackage /home/mig/nixpkgs/pkgs/by-name/na/navicat-premium/package.nix {};
in
{
  imports =
    [
      aagl.module
    ];
  programs.anime-game-launcher.enable = true;

  environment.systemPackages = with pkgs; [
    (pkgs.python3.withPackages (python-pkgs: [
      python-pkgs.psutil
    ]))
    git
    niri
    # foot
    neovim
    firefox
    xfce.thunar
    xfce.thunar-volman
    gvfs
    pipewire    
    libreoffice
    waybar
    yambar
    swww
    xwayland-satellite
    swayosd
    htop
    pavucontrol # test if pwvucontrol works as good as pavucontrol
    pwvucontrol
    ludusavi
    osu-lazer-bin
    keepassxc
    # mpv
    nvtopPackages.full
    nomacs
    wl-clipboard
    xorg.xeyes
    qalculate-gtk
    localsend
    heroic
    gnome-themes-extra
    transmission_4-gtk
    prismlauncher
    lazygit
    grim
    obs-studio
    clang
    rustc
    cargo
    appimage-run
    swaylock
    jellyfin-media-player
    mysql-workbench
    php
    sqlite
    sway
    wofi
    python3
    ripunzip
    amberol
    joplin-desktop
    tenacity
    bluetuith
    # dependencies for nvchad
    unzip
    clang-tools
    phpactor
    
    wl-mirror
    ollama-cuda
    ciscoPacketTracer8
    navicat
    rsync

    dock-script
    undock-script
    firefox-sync
  ];
  systemd.user.services.firefox-profile-memory-cache = {
    description = "Firefox profile memory cache";
    wantedBy = [ "default.target" ];
    path = [pkgs.rsync];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = ''${firefox-sync}/bin/firefox-sync 0shu6evv.default'';
      ExecStop = ''${firefox-sync}/bin/firefox-sync 0shu6evv.default'';
    };
  };
}
