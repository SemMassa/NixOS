{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    <nixos-hardware/apple/t2>
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Binary cache for the T2 kernel (verify key in t2linux wiki)
  nix.settings = {
    substituters = [ "https://cache.soopy.moe" ];
    trusted-public-keys = [ "cache.soopy.moe-1:0RZVsQeR+GOh0VQI9rvnHz55nVXkFardDqfm4+afjPo=" ];
  };

  # Broadcom firmware extracted from macOS, stored in ./firmware
  hardware.enableRedistributableFirmware = true;
  hardware.firmware = [
    (pkgs.stdenvNoCC.mkDerivation {
      name = "brcm-firmware";
      buildCommand = ''
        dir="$out/lib/firmware"
        mkdir -p "$dir"
        cp -r ${./firmware}/* "$dir"
      '';
    })
  ];

  # Network
  networking.networkmanager.enable = true;
  networking.hostName = "nixos-t2";

  # Locale and keyboard
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";
  console.keyMap = "de";

  # X11 with i3
  services.xserver = {
    enable = true;
    xkb.layout = "de";
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu
        i3status
        i3lock
      ];
    };
  };

  # Login screen
  services.displayManager.defaultSession = "none+i3";
  services.xserver.displayManager.lightdm.enable = true;

  # Keyboard workaround for Firefox and GTK (remove if not needed)
  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "0";
    GTK_IM_MODULE = "none";
  };

  # Audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # User (replace "alex" with your username)
  users.users.alex = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
  };

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    firefox
    alacritty
  ];

  nixpkgs.config.allowUnfree = true;

  # Keep the value from your installer
  system.stateVersion = "24.05";
}
