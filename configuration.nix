{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    # T2-Hardware-Modul aus nixos-hardware (wird über Flakes oder Channel eingebunden)
    # <nixos-hardware/apple/t2>
  ];

  # T2-Spezifische Firmware & Kernel
  hardware.apple-t2.enable = true;

  # Bootloader für Mac EFI
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Netzwerkeinstellungen
  networking.hostName = "mac-nixos";
  networking.networkmanager.enable = true;

  # X11 & i3 Window Manager Setup
  services.xserver = {
    enable = true;
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        polybarFull
        rofi
        dmenu
        i3lock
      ];
    };
  };

  # Tastatur-Layout
  console.keyMap = "de";
  services.xserver.xkb = {
    layout = "de";
    variant = "mac"; # Optimiert für Mac-Tastaturlayout
  };

  # Audio (PipeWire für T2 Audio-Unterstützung)
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # Systemweite Pakete
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
    alacritty
    font-awesome
    nerd-fonts.jetbrains-mono
  ];

  # Benutzer
  users.users.alex = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
    ];
  };

  system.stateVersion = "24.11";
}
