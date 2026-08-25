{ config, lib, pkgs, ... }:

{
  nix.settings.experimental-features = ["nix-command" "flakes"];

  imports = [
    ./hardware-configuration.nix
  ];

  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 8000 22 ];
  services.openssh.enable = true;

  time.timeZone = "Europe/London";

  ################################
  # X11 + i3
  ################################
  services.xserver = {
    enable = true;

    displayManager.startx.enable = true;
    displayManager.lightdm.enable = false;

    windowManager.i3 = {
      enable = true;
      package = pkgs.i3;

      extraSessionCommands = '' 
        exec --no-startup-id xrandr --output DP-2 --auto --primary --output HDMI-0 --auto --right-of DP-2 --rotate left

        workspace 1 output DP-2
        workspace 2 output HDMI-0
      '';
    };

    xkb.layout = "gb";
    videoDrivers = [ "intel" "nvidia" ];
  };

  ################################
  # NVIDIA
  ################################
  boot.kernelParams = [
    "acpi_backlight=vendor"
    "nvidia.NVreg_EnableBacklightHandler=1"
  ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };

  services.blueman.enable = true;

  ################################
  # Portals
  ################################
  programs.dconf.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    xdgOpenUsePortal = true;
    config.common.default = [ "gtk" ];
  };

  services.dbus.enable = true;

  # i3 file dialog portal fix
  environment.sessionVariables = {
    GTK_USE_PORTAL = "0";
  };

  ################################
  # Users
  ################################
  users.users.alice = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.bash;
  };

  security.sudo.enable = true;

  ################################
  # Audio
  ################################

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true; 
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  }; 

  ################################
  # Containerisation 
  ################################
  virtualisation.podman.enable = true;
  virtualisation.containers.enable = true;

  ################################
  # Packages
  ################################
  environment.systemPackages = with pkgs; [
    vim
    alacritty
    xorg.xinit
    git
    tmux
    bash-completion
    firefox
    yt-dlp
    mpv
    python3
    gtk4
    man-pages
    nodejs_24
    gdb

    pulseaudio
    anki-bin

    ripgrep
    fd

    openvpn
  ];

  programs.fzf = {
    keybindings = true;
    fuzzyCompletion = true;
  };

  system.stateVersion = "25.11";
}

