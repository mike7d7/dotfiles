{
  pkgs,
  lib,
}: let
  rebuild-normal-script = pkgs.writeShellScriptBin "rebuild-normal" ''
    nixos-rebuild switch --elevate=sudo
  '';
  rebuild-local-cache-script = pkgs.writeShellScriptBin "rebuild-local-cache" ''
    sudo nixos-rebuild switch --option substituters "http://192.168.0.156:8080/local-cache"
  '';
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
in {
  packages = [
    # pkgs.texlive.combined.scheme-full
    rebuild-normal-script
    rebuild-local-cache-script
    backup-script
    firefox-sync
  ];
  inherit firefox-sync;
}
