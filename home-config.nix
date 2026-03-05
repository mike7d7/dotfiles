{
  pkgs,
  lib,
  pkgs-stable,
  ...
}:
{
  # The home.stateVersion option does not have a default and must be set
  home.stateVersion = "24.05";
  # home.packages = with pkgs; [];

  # Programs
  programs.bash.enable = true;
  programs.foot.enable = true;
  programs.mpv.enable = true;
  programs.yazi.enable = true;
  gtk.enable = true;
  services.swayosd.enable = true;

  # Configs
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "mike7d7";
        email = "mike7d7@proton.me";
      };
    };
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

  programs.yazi = {
    plugins = {
      mount = pkgs.yaziPlugins.mount;
      ouch = pkgs.yaziPlugins.ouch;
      recycle-bin = pkgs.yaziPlugins.recycle-bin;
    };
    initLua = "require(\"recycle-bin\"):setup()";
    keymap = {
      mgr.prepend_keymap = [
        {
          on = "n";
          run = "arrow next";
        }
        {
          on = "e";
          run = "arrow prev";
        }
        {
          on = "N";
          run = "arrow 5";
        }
        {
          on = "E";
          run = "arrow -5";
        }

        {
          on = "<C-l>";
          run = "arrow -50%";
        }
        {
          on = "<C-s>";
          run = "arrow 50%";
        }
        {
          on = "<C-t>";
          run = "arrow 100%";
        }

        {
          on = [
            "d"
            "d"
          ];
          run = "arrow top";
        }
        {
          on = "D";
          run = "arrow bot";
        }

        {
          on = "i";
          run = "enter";
        }
        {
          on = "I";
          run = "forward";
        }

        {
          on = "<C-y>";
          run = "toggle_all --state=on";
        }
        {
          on = "<C-p>";
          run = "toggle_all";
        }

        {
          on = "y";
          run = "open";
        }
        {
          on = "Y";
          run = "open --interactive";
        }

        {
          on = "ñ";
          run = "paste";
        }
        {
          on = "Ñ";
          run = "paste --force";
        }

        {
          on = "s";
          run = "remove";
        }
        {
          on = "S";
          run = "remove --permanently";
        }

        {
          on = "p";
          run = "rename --cursor=before_ext";
        }

        {
          on = "f";
          run = "filter --smart";
          desc = "Filter files";
        }

        {
          on = "F";
          run = "search --via=fd";
        }

        {
          on = "g";
          run = "tab_create --current";
        }
        {
          on = "j";
          run = "yank";
        }
        {
          on = "J";
          run = "unyank";
        }

        {
          on = "M";
          run = "plugin mount";
          desc = "Open mount plugin";
        }

        {
          on = "<C-k>";
          run = "shell 'ripdrag \"$@\" -dx 2>/dev/null &' --confirm";
        }

        {
          on = "C";
          run = "plugin ouch";
          desc = "Compress with ouch";
        }

        {
          on = [
            "d"
            "g"
          ];
          run = "cd ~/Documents/Tarea";
        }
        {
          on = [
            "d"
            "l"
          ];
          run = "cd ~/.local";
        }
        {
          on = [
            "d"
            "c"
          ];
          run = "cd ~/.config";
        }
        {
          on = [
            "d"
            "h"
          ];
          run = "cd ~/";
        }
        {
          on = [
            "d"
            "s"
          ];
          run = "cd ~/Downloads";
        }

        {
          on = [
            "d"
            "<Space>"
          ];
          run = "cd --interactive";
          desc = "Jump interactively";
        }

        {
          on = "<A-u>";
          run = "shell 'foot -d none' --orphan";
        }

        {
          on = [
            "R"
            "y"
          ];
          run = "plugin recycle-bin -- open";
        }
        {
          on = [
            "R"
            "f"
          ];
          run = "plugin recycle-bin -- empty";
        }
        {
          on = [
            "R"
            "S"
          ];
          run = "plugin recycle-bin -- emptyDays";
        }
        {
          on = [
            "R"
            "r"
          ];
          run = "plugin recycle-bin -- delete";
        }
        {
          on = [
            "R"
            "p"
          ];
          run = "plugin recycle-bin -- restore";
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
      open = {
        prepend_rules = [
          {
            name = "*.zip";
            use = "extract";
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
      cursor-theme = "graphite-dark";
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
    gtk-cursor-theme-name = "graphite-dark";
  };
  gtk.gtk4.extraConfig = {
    gtk-icon-theme-name = "Adwaita";
    gtk-theme-name = "Adwaita-dark";
    gtk-application-prefer-dark-theme = 1;
    gtk-cursor-theme-name = "graphite-dark";
  };
  qt = {
    enable = true;
    platformTheme.name = "qtct";
    # style.name = "kvantum";
  };
  xdg.configFile."Kvantum/kvantum.kvconfig".source =
    (pkgs.formats.ini { }).generate "kvantum.kvconfig"
      {
        General.theme = "KvAdaptaDark";
      };
  home.pointerCursor = {
    gtk.enable = true;
    name = "graphite-dark";
    package = pkgs.graphite-cursors;
    size = 32;
  };
  programs.mpv.config = {
    hwdec = "vaapi";
    hwdec-codecs = "all";
    gpu-api = "opengl";
  };
  # xdg.configFile."niri/config.kdl".source = ./configs/config.kdl;
  xdg.configFile."matugen/config.toml".source = ./configs/matugen/config.toml;
  xdg.configFile."niri/config.kdl".source = ./configs/niri-config.kdl;
}
