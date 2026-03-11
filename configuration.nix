# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ pkgs, ... }:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./packages.nix
    ./graphics.nix
  ];
  hardware = {
    bluetooth = {

      enable = true; # enables support for bluetooth
      powerOnBoot = false; # powers up the default Bluetooth controller on boot
    };
  };

  boot = {
    kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-lts-x86_64-v3;
    kernelParams = [
      "nowatchdog"
      "preempt=full"
      "rcutree.enable_rcu_lazy=1"
    ];
    kernelModules = [ "ntsync" ];

    # Bootloader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "nixos"; # Define your hostname.
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Enable networking
    networkmanager = {
      enable = true;
      plugins = with pkgs; [
        networkmanager-openvpn
      ];
    };
    useDHCP = false;
  };
  systemd.network = {
    enable = true;
    networks = {
      "90-interfaces" = {
        matchConfig = {
          Name = "*";
        };
        DHCP = "yes";
      };
    };
  };

  # Set your time zone.
  time.timeZone = "America/Mexico_City";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "latam";
    variant = "";
    extraLayouts.latam-code = rec {
      description = "Programmers Colemak with less and greater than mapped to AltGr + z/x";
      languages = [ "latam" ];
      symbolsFile = builtins.toFile "symbols-latam-code" ''
        partial alphanumeric_keys
        xkb_symbols "latam-code" {
            include "latam(colemak)"

            name[Group1]="${description}";

            key <AB01>	{ [         z,          Z, guillemotleft,        less ]	};
            key <AB02>	{ [         x,          X, guillemotright,    greater ]	};
        };
      '';
    };
  };

  # Configure console keymap
  console.keyMap = "la-latin1";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mig = {
    isNormalUser = true;
    description = "mig";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    # packages = with pkgs; [ ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    liberation_ttf
    dejavu_fonts
    nerd-fonts.jetbrains-mono
    fira-code
  ];
  fonts.fontDir.enable = true;
  services = {
    howdy = {
      enable = true;
      control = "sufficient";
    };
    linux-enable-ir-emitter.enable = true;
    printing.enable = true;
    printing.drivers = [ pkgs.epson-escpr2 ];
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    pcscd.enable = true;
    gvfs.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;
      extraConfig.pipewire."92-low-latency" = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.quantum" = 128;
          "default.clock.min-quantum" = 32;
          "default.clock.max-quantum" = 256;
        };
      };
      wireplumber.extraConfig."10-bluez" = {
        "monitor.bluez.properties" = {
          "bluez5.enable-sbc-xq" = true;
          "bluez5.enable-msbc" = true;
          "bluez5.enable-hw-volume" = true;
          "bluez5.headset-roles" = [
            "hsp_hs"
            "hsp_ag"
            "hfp_hf"
            "hfp_ag"
          ];
        };
      };
    };
    udev = {
      packages = [
        (pkgs.writeTextFile {
          name = "my-rules";
          text = ''
            KERNEL=="hidraw*", ATTRS{idVendor}=="056a", ATTRS{idProduct}=="0374", TAG+="uaccess", TAG+="udev-acl"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="056a", ATTRS{idProduct}=="0374", TAG+="uaccess", TAG+="udev-acl"
          '';
          destination = "/etc/udev/rules.d/70-opentabletdriver.rules";
        })
      ]
      ++ [
        pkgs.oversteer
        pkgs.usb-modeswitch-data
      ];
      extraRules = ''
        ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c294", RUN+="${pkgs.usb-modeswitch}/bin/usb_modeswitch -v 046d -p c294 -m 01 -r 01 -C 03 -M '0f00010142'"
      '';
    };
    logind.settings.Login.HandleLidSwitchExternalPower = "ignore";
    asusd = {
      enable = true;
    };
    upower.enable = true;

    displayManager.dms-greeter = {
      enable = true;
      compositor.name = "niri";
      configHome = "/home/mig";
      logs = {
        save = false;
        path = "/tmp/dms-greeter.log";
      };
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  programs = {
    niri = {
      enable = true;
    };
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    dconf.enable = true;
    # Make Firefox use the KDE file picker.
    # Preferences source: https://wiki.archlinux.org/title/firefox#KDE_integration
    firefox = {
      enable = true;
      preferences = {
        "widget.use-xdg-desktop-portal.file-picker" = 1;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "svg.context-properties.content.enabled" = true;
      };
    };
    nvf = {
      enable = true;
      settings = import ./nvf-config.nix;
    };
    dms-shell = {
      enable = true;
      systemd = {
        enable = true;
        restartIfChanged = true;
      };
      enableCalendarEvents = false;
      quickshell.package = inputs.quickshell.packages.${pkgs.system}.default;
    };
  };
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      kdePackages.xdg-desktop-portal-kde
      xdg-desktop-portal-gnome
    ];
  };
  # Most of this is copied from niri's config, except the KDE FileChooser
  xdg.portal.config = {
    niri = {
      default = [
        "gnome"
        "gtk"
      ];
      "org.freedesktop.impl.portal.Access" = [ "gtk" ];
      "org.freedesktop.impl.portal.Notification" = [ "gtk" ];
      "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      "org.freedesktop.impl.portal.FileChooser" = [ "kde" ];
    };
  };
  # services.flatpak.enable = true;
  security.rtkit.enable = true;
  security = {
    pam.howdy.enable = true;
  };
  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    58396
    631
    53317
    12345
  ];
  networking.firewall.allowedUDPPorts = [
    631
    53317
  ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

  programs.bash.promptInit = ''
    PS1='\[\e[0m\][\[\e[1;36m\]\u\[\e[0m\]@\[\e[1;36m\]\h\[\e[0m\] \W]\$ '
  '';
  programs.steam = {
    enable = true;
    extraCompatPackages = with pkgs; [ proton-ge-bin ];
  };
  hardware.logitech.wireless.enable = true;
  hardware.new-lg4ff.enable = true;
}
