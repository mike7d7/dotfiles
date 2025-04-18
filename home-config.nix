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
  yazi-flavors = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "flavors";
    rev = "68326b4ca4b5b66da3d4a4cce3050e5e950aade5";
    hash = "sha256-nhIhCMBqr4VSzesplQRF6Ik55b3Ljae0dN+TYbzQb5s=";
  };
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
    programs.yazi.enable = true;
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
      userKeymaps = builtins.fromJSON (builtins.readFile ./configs/zed/keymap.json);
      userSettings = builtins.fromJSON (builtins.readFile ./configs/zed/settings.json);
      extraPackages = with pkgs; [
        nil
        nixfmt-rfc-style
        tinymist
        typstyle
        clang-tools
      ];
    };
    xdg.configFile."zed/tasks.json".source = ./configs/zed/tasks.json;
    xdg.configFile."zed/themes/custom-theme-1.json".source = ./configs/zed/themes/custom-theme-1.json;

    programs.yazi = {
      plugins = {
        mount = pkgs.yaziPlugins.mount;
        ouch = pkgs.yaziPlugins.ouch;
      };
      flavors = {
        catppuccin-mocha = "${yazi-flavors}/catppuccin-mocha.yazi";
      };
      keymap = {
        manager.prepend_keymap = [
          {
            on = "M";
            run = "plugin mount";
            desc = "Open mount plugin";
          }
          {
            on = "<S-j>";
            run = "arrow 5";
            desc = "Move cursor down 5 positions";
          }
          {
            on = "<S-k>";
            run = "arrow -5";
            desc = "Move cursor up 5 positions";
          }
          {
            on = [ "<C-n>" ];
            run = "shell 'ripdrag \"$@\" -dx 2>/dev/null &' --confirm";
          }
          {
            on = "C";
            run = "plugin ouch";
            desc = "Compress with ouch";
          }
        ];
      };
      settings = {
        opener = {
          play = [
            {
              run = "mpv \"$@\"";
              orphan = true;
              for = "unix";
            }
          ];
          edit = [
            {
              run = "nvim \"$@\"";
              block = true;
              for = "unix";
            }
          ];
          open = [
            {
              run = "xdg-open \"$@\"";
              desc = "Open";
            }
          ];
          extract = [
            {
              run = "ouch d -y \"$@\"";
              desc = "Extract here with ouch";
              for = "unix";
            }
          ];
        };
        plugin = {
          prepend_previewers = [
            {
              mime = "application/*zip";
              run = "ouch";
            }
            {
              mime = "application/x-tar";
              run = "ouch";
            }
            {
              mime = "application/x-bzip2";
              run = "ouch";
            }
            {
              mime = "application/x-7z-compressed";
              run = "ouch";
            }
            {
              mime = "application/x-rar";
              run = "ouch";
            }
            {
              mime = "application/x-xz";
              run = "ouch";
            }
            {
              mime = "application/xz";
              run = "ouch";
            }
          ];
        };
      };
    };

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
    xdg.configFile."eww/eww.scss".source = ./configs/eww/eww.scss;
    xdg.configFile."eww/eww.yuck".source = ./configs/eww/eww.yuck;
    xdg.configFile."eww/modules/battery.yuck".source = ./configs/eww/modules/battery.yuck;
    xdg.configFile."eww/modules/clock.yuck".source = ./configs/eww/modules/clock.yuck;
    xdg.configFile."eww/modules/cpu.yuck".source = ./configs/eww/modules/cpu.yuck;
    xdg.configFile."eww/modules/focused-window.yuck".source = ./configs/eww/modules/focused-window.yuck;
    xdg.configFile."eww/modules/network.yuck".source = ./configs/eww/modules/network.yuck;
    xdg.configFile."eww/modules/niri-workspaces.yuck".source =
      ./configs/eww/modules/niri-workspaces.yuck;
    xdg.configFile."eww/modules/ram.yuck".source = ./configs/eww/modules/ram.yuck;
    xdg.configFile."eww/modules/temp.yuck".source = ./configs/eww/modules/temp.yuck;
    xdg.configFile."eww/modules/calendar.yuck".source = ./configs/eww/modules/calendar.yuck;
    xdg.configFile."eww/scripts/niri-focused-window.sh".source =
      ./configs/eww/scripts/niri-focused-window.sh;
    xdg.configFile."eww/scripts/niri-workspaces.sh".source = ./configs/eww/scripts/niri-workspaces.sh;
    xdg.configFile."eww/scripts/nmcli-monitor.sh".source = ./configs/eww/scripts/nmcli-monitor.sh;
    xdg.configFile."eww/scripts/calendar.sh".source = ./configs/eww/scripts/calendar.sh;
    xdg.configFile."eww/scripts/multimonitor.sh".source = ./configs/eww/scripts/multimonitor.sh;
  };
}
