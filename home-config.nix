{ config, pkgs, ... }:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
  swayosd-fixed = pkgs.swayosd.overrideAttrs (oldAttrs: {
    src = pkgs.fetchFromGitHub {
      owner = "soraxas";
      repo = "SwayOSD";
      rev = "20f834e1e563c603d456b2e5da05a4e65b6e3e10";
      sha256 = "sha256-GuzFqaHl7W5Vrjalb0Wl6iKmY/xWZ7Dbuyo0X7NN7R4=";
    };
  });
in
{
  imports = [
    (import "${home-manager}/nixos")
  ];

  home-manager.users.mig = {
    # The home.stateVersion option does not have a default and must be set
    home.stateVersion = "24.05";
    # Here goes the rest of your home-manager config, e.g. home.packages = [ pkgs.foo ];

    # Programs
    programs.bash.enable = true;
    programs.foot.enable = true;
    programs.mpv.enable = true;
    programs.tofi.enable = true;
    programs.zed-editor.enable = true;
    gtk.enable = true;
    services.swayosd.enable = true;
    services.swayosd.package = swayosd-fixed;

    # Configs
    programs.git = {
      enable = true;
      userName = "mike7d7";
      userEmail = "mike7d7@proton.me";
    };

    programs.foot.settings = {
      main = {
        font = "liberation mono:size=14";
        dpi-aware = false;
      };

      colors = {
        alpha = 0.7;
        background = "000000";
        foreground = "FFFFFF";
        ## Normal/regular colors (color palette 0-7)
        regular0 = "000000"; # black
        regular1 = "cd0000"; # red
        regular2 = "00cd00"; # green
        regular3 = "cdcd00"; # yellow
        regular4 = "0000ee"; # blue
        regular5 = "cd00cd"; # magenta
        regular6 = "00cdcd"; # cyan
        regular7 = "e5e5e5"; # white

        ## Bright colors (color palette 8-15)
        bright0 = "7f7f7f"; # bright black
        bright1 = "ff0000"; # bright red
        bright2 = "00ff00"; # bright green
        bright3 = "ffff00"; # bright yellow
        bright4 = "5c5cff"; # bright blue
        bright5 = "ff00ff"; # bright magenta
        bright6 = "00ffff"; # bright cyan
        bright7 = "ffffff"; # bright white
      };
    };
    programs.zed-editor = {
      extensions = [
        "log"
        "nix"
        "basher"
        "typst"
      ];
      userKeymaps = builtins.fromJSON (builtins.readFile ./configs/keymap.json);
      userSettings = builtins.fromJSON (builtins.readFile ./configs/settings.json);
      extraPackages = with pkgs; [
        nil
        nixfmt-rfc-style
        tinymist
        typstyle
        clang-tools
      ];
    };
    xdg.configFile."zed/tasks.json".source = ./configs/tasks.json;

    dconf.settings = {
      "org/gnome/desktop/interface" = {
        cursor-theme = "macOS";
      };
    };

    gtk.gtk3.bookmarks = [
      "file:///home/mig/Desktop"
      "file:///home/mig/Documents"
      "file:///home/mig/Videos"
      "file:///home/mig/Music"
      "file:///home/mig/Images"
      "file:///home/mig/Downloads"
    ];
    gtk.gtk3.extraConfig = {
      gtk-icon-theme-name = "Adwaita";
      gtk-theme-name = "Adwaita-dark";
      gtk-application-prefer-dark-theme = 1;
      gtk-cursor-theme-name = "macOS";
    };
    gtk.gtk4.extraConfig = {
      gtk-icon-theme-name = "Adwaita";
      gtk-theme-name = "Adwaita-dark";
      gtk-application-prefer-dark-theme = 1;
      gtk-cursor-theme-name = "macOS";
    };
    home.pointerCursor = {
      gtk.enable = true;
      name = "macOS";
      package = pkgs.apple-cursor;
      size = 32;
    };
    programs.mpv.config = {
      hwdec = "vaapi";
      hwdec-codecs = "all";
      gpu-api = "opengl";
    };
    programs.tofi.settings = {
      width = "100%";
      height = "100%";
      border-width = 0;
      outline-width = 0;
      padding-left = "35%";
      padding-top = "35%";
      result-spacing = 25;
      num-results = 5;
      font = "/nix/var/nix/profiles/system/sw/share/X11/fonts/JetBrainsMonoNerdFont-Medium.ttf";
      hint-font = false;
      background-color = "#000A";
      ascii-input = true;
      selection-color = "#7fc8ff";
      drun-launch = false;
    };
    xdg.configFile."Thunar/uca.xml".source = ./configs/thunar.uca.xml;
    xdg.configFile."niri/config.kdl".source = ./configs/config.kdl;
  };
}
