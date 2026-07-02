# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./packages.nix
    ./graphics.nix
    inputs.nixvirt.nixosModules.default
  ];
  hardware = {
    bluetooth = {

      enable = true; # enables support for bluetooth
      powerOnBoot = false; # powers up the default Bluetooth controller on boot
    };
  };

  boot = {
    kernelPackages = pkgs.linuxKernel.packagesFor inputs.custom-kernel.packages."x86_64-linux".default;
    kernelParams = [
      "nowatchdog"
      "preempt=full"
      "rcutree.enable_rcu_lazy=1"
    ];
    kernelModules = [ "ntsync" ];

    # Bootloader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    extraModprobeConfig = ''
      options kvm_intel nested=1
    '';
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
      "libvirtd"
      "podman"
      "kvm"
    ];
    # packages = with pkgs; [ ];
  };
  users.groups.libvirtd.members = [ "mig" ];

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
    tor = {
      enable = true;
      client.enable = true;
      settings = {
        ExitNodes = "{mx}";
        StrictNodes = true;
      };
    };
    privoxy = {
      enable = true;
      enableTor = true;
    };
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
      wireplumber.configPackages = [
        (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/alsa.conf" ''
          monitor.alsa.rules = [
            {
              matches = [
                {
                  device.name = "~alsa_card.*"
                }
              ]
              actions = {
                update-props = {
                  # Device settings
                  api.alsa.use-acp = true
                }
              }
            }
            {
              matches = [
                {
                  node.name = "~alsa_input.pci.*"
                }
              ]
              actions = {
              # Node settings
                update-props = {
                  session.suspend-timeout-seconds = 0
                }
              }
            }
          ]
        '')
      ];
    };
    udev = {
      packages = [
        (pkgs.writeTextFile {
          name = "my-rules";
          text = ''
            KERNEL=="hidraw*", ATTRS{idVendor}=="056a", ATTRS{idProduct}=="0374", TAG+="uaccess", TAG+="udev-acl"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="056a", ATTRS{idProduct}=="0374", TAG+="uaccess", TAG+="udev-acl"
            # Wacom CTH-480
            KERNEL=="hidraw*", ATTRS{idVendor}=="056a", ATTRS{idProduct}=="0302", TAG+="uaccess", TAG+="udev-acl"
            SUBSYSTEM=="usb", ATTRS{idVendor}=="056a", ATTRS{idProduct}=="0302", TAG+="uaccess", TAG+="udev-acl"
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

  virtualisation = {
    podman.enable = true;
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
    virt-manager.enable = true;
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
        # Rapidfox
        "network.http.max-connections" = 1200;
        "network.http.max-persistent-connections-per-server" = 8;
        "network.http.max-urgent-start-excessive-connections-per-host" = 5;
        "network.http.request.max-start-delay" = 5;
        "network.http.pacing.requests.enabled" = false; # disable on slow connections
        "network.http.pacing.requests.burst" = 32;
        "network.http.pacing.requests.min-parallelism" = 16;
        "network.dnsCacheExpiration" = 600;
        "network.dnsCacheExpirationGracePeriod" = 120;
        "network.dnsCacheEntries" = 10000;
        "network.ssl_tokens_cache_capacity" = 32768;
        "network.http.speculative-parallel-limit" = 0;
        "network.dns.disablePrefetch" = true;
        "network.dns.disablePrefetchFromHTTPS" = true;
        "network.prefetch-next" = false;
        "network.predictor.enabled" = false;
        "network.predictor.enable-prefetch" = false;
        "browser.urlbar.speculativeConnect.enabled" = false;
        "browser.places.speculativeConnect.enabled" = false;
        "javascript.options.mem.high_water_mark" = 128;
        "browser.cache.disk.enable" = false;
        "browser.cache.disk.capacity" = 0;
        "browser.cache.memory.capacity" = 131072;
        "browser.cache.disk.smart_size.enabled" = false;
        "browser.cache.memory.max_entry_size" = 32768;
        "browser.cache.disk.metadata_memory_limit" = 16384;
        "browser.cache.max_shutdown_io_lag" = 100;
        "image.mem.max_decoded_image_kb" = 512000;
        "image.cache.size" = 10485760;
        "image.mem.decode_bytes_at_a_time" = 65536;
        "image.mem.shared.unmap.min_expiration_ms" = 90000;
        "media.memory_cache_max_size" = 1572864;
        "media.memory_caches_combined_limit_kb" = 6291456;
        "media.cache_readahead_limit" = 600;
        "media.cache_resume_threshold" = 300;
        "dom.storage.default_quota" = 20480;
        "dom.storage.shadow_writes" = true;
        "browser.sessionstore.interval" = 60000;
        "browser.sessionhistory.max_total_viewers" = 10;
        "browser.sessionstore.max_tabs_undo" = 10;
        "browser.sessionstore.max_entries" = 10;
        "browser.tabs.min_inactive_duration_before_unload" = 600000;
        "content.maxtextrun" = 8191;
        "content.interrupt.parsing" = true;
        "content.notify.ontimer" = true;
        "content.notify.interval" = 80000;
        "content.max.tokenizing.time" = 2000000;
        "content.switch.threshold" = 300000;
        "layout.frame_rate" = -1;
        "nglayout.initialpaint.delay" = 5;
        "gfx.content.skia-font-cache-size" = 32;
        "gfx.webrender.all" = true;
        "gfx.webrender.enabled" = true;
        "gfx.webrender.compositor" = true;
        "gfx.webrender.precache-shaders" = true;
        "gfx.webrender.software" = false;
        "layers.acceleration.force-enabled" = true;
        "gfx.canvas.accelerated.cache-items" = 32768;
        "gfx.canvas.accelerated.cache-size" = 4096;
        "gfx.canvas.max-size" = 16384;
        "webgl.max-size" = 16384;
        "dom.webgpu.enabled" = true;
        "webgl.force-enabled" = true;
        "ui.submenuDelay" = 0;
        "browser.uidensity" = 0;
        "dom.element.animate.enabled" = true;
        "general.smoothScroll" = true;
        "general.smoothScroll.msdPhysics.enabled" = false;
        "general.smoothScroll.currentVelocityWeighting" = 0;
        "apz.overscroll.enabled" = false;
        "general.smoothScroll.stopDecelerationWeighting" = 1;
        "general.smoothScroll.mouseWheel.durationMaxMS" = 150;
        "general.smoothScroll.mouseWheel.durationMinMS" = 50;
        "mousewheel.min_line_scroll_amount" = 18;
        "mousewheel.scroll_series_timeout" = 10;
        "dom.ipc.processCount" = 12;
        "dom.ipc.keepProcessesAlive.web" = 4;
        "accessibility.force_disabled" = 1;
        "dom.media.webcodecs.h265.enabled" = true;
        "media.ffmpeg.vaapi.enabled" = true;
        "media.hardware-video-decoding.force-enabled" = true;
        "privacy.query_stripping.enabled" = true;
        "privacy.query_stripping.enabled.pbmode" = true;
        "network.http.referer.XOriginPolicy" = 0;
        "network.http.referer.XOriginTrimmingPolicy" = 0;
        "browser.safebrowsing.downloads.remote.enabled" = false;
        "widget.wayland.opaque-region.enabled" = true;
        "widget.wayland.fractional-scale.enabled" = true;
        "browser.search.suggest.enabled" = false;
        "browser.urlbar.suggest.searches" = false;
        "browser.findBar.suggest.enabled" = false;
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
  networking.firewall = {
    allowedTCPPorts = [
      58396
      631
      53317
      12345
      8006
    ];
    allowedUDPPorts = [
      631
      53317
      8006
    ];
  };
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
