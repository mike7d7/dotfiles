{
  pkgs,
  ...
}:
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
  # nixpkgsPinned = import (builtins.fetchTarball {
  #   url = "https://github.com/NixOS/nixpkgs/archive/f64072cc7ad8341df63a6f2f095c961a7050dbc0.tar.gz";
  # }) { };
in
{
  nixpkgs.overlays = [
    (final: prev: {
      ouch = prev.ouch.override { enableUnfree = true; };
    })
  ];
  environment.systemPackages = with pkgs; [
    git
    niri
    neovim
    pipewire
    libreoffice
    onlyoffice-desktopeditors
    hunspell
    hunspellDicts.es_MX
    hunspellDicts.en_US
    eww
    jq
    jaq
    swww
    xwayland-satellite
    htop
    pwvucontrol
    ludusavi
    osu-lazer-bin
    keepassxc
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
    rustup
    cargo
    swaylock
    ripunzip
    gapless
    joplin-desktop
    tenacity
    bluetuith
    # dependencies for nvchad
    unzip

    wl-mirror
    rsync
    _7zz
    gnupg
    pinentry-tty
    apple-cursor
    kdePackages.dolphin
    kdePackages.qtsvg
    kdePackages.kio-fuse # to mount remote filesystems via FUSE
    kdePackages.kio-extras # extra protocols support (sftp, fish and more)

    waypaper
    ripdrag
    jftui
    ouch
    rquickshare
    wineWow64Packages.stagingFull
    solaar # fixes bug with wireless logitech keyboard
    epsonscan2
    mcpelauncher-ui-qt
    discord

    dock-script
    undock-script
    firefox-sync
  ];
  systemd.user.services.firefox-profile-memory-cache = {
    description = "Firefox profile memory cache";
    wantedBy = [ "default.target" ];
    path = [ pkgs.rsync ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = ''${firefox-sync}/bin/firefox-sync 0shu6evv.default'';
      ExecStop = ''${firefox-sync}/bin/firefox-sync 0shu6evv.default'';
    };
  };
}
