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
  # networking.firewall.allowedTCPPorts = [ 8000 ];

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
        exec --no-startup-id xrandr --output DP-2 --auto --primary --output DP-0 --auto --right-of DP-2 --rotate left

        workspace 1 output DP-2
        workspace 2 output DP-0

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

  hardware.pulseaudio.enable = false;

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    extraConfig = {
      pipewire."10-echo-cancel" = {
        "context.modules" = [
          {
            name = "libpipewire-module-echo-cancel";
            args = {
              "aec.method" = "webrtc";
              "aec.args" = {
                "noise_suppression" = true;
                "noise_suppression_level" = 3; 
                "voice_detection" = true;
              };

              "source.props" = {
                "node.name" = "echo_cancel_source";
                "node.description" = "Noise-suppressed Microphone";
              };
            };
          }
        ];
      };
    };
  }; 

  programs.noisetorch.enable = true;

  ################################
  # Packages
  ################################
  environment.systemPackages = with pkgs; [
    vim
    wget
    alacritty
    xorg.xinit
    git
    tmux
    bash-completion
    firefox
    yt-dlp
    mpv
    python3
    anki
    vscode
    legcord
    pulseaudio
    gtk4
    man-pages
  ];

  system.stateVersion = "26.05";
}

