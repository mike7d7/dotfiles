# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./packages.nix
    ./graphics.nix
    ./home-config.nix
  ];
  hardware.bluetooth.enable = true; # enables support for bluetooth
  hardware.bluetooth.powerOnBoot = false; # powers up the default Bluetooth controller on boot

  services.scx.enable = true;
  services.scx.scheduler = "scx_lavd"; # default is "scx_rustland"
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "nowatchdog" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.useDHCP = false;
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
    packages = with pkgs; [ ];
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
  security.pam.services.swaylock = { };
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.epson-escpr2 ];
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
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
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  services.pcscd.enable = true;
  xdg.portal.config.common.default = "*";
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
    ];
  };
  programs.dconf.enable = true;
  services.gvfs.enable = true;
  services.flatpak.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };
  services.pipewire.wireplumber.extraConfig."10-bluez" = {
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
  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    58396
    631
    53317
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
  services.udev.packages = lib.singleton (
    pkgs.writeTextFile {
      name = "my-rules";
      text = ''
        	  KERNEL=="hidraw*", ATTRS{idVendor}=="056a", ATTRS{idProduct}=="0374", TAG+="uaccess", TAG+="udev-acl"
        	  SUBSYSTEM=="usb", ATTRS{idVendor}=="056a", ATTRS{idProduct}=="0374", TAG+="uaccess", TAG+="udev-acl"
      '';
      destination = "/etc/udev/rules.d/70-opentabletdriver.rules";
    }
  );
  programs.bash.promptInit = ''
    PS1='\[\e[0m\][\[\e[1;36m\]\u\[\e[0m\]@\[\e[1;36m\]\h\[\e[0m\] \W]\$ '
  '';
}
