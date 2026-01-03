{ config, lib, pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  time.timeZone = "Europe/London";

  users.users.alice = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; 
    shell = pkgs.bash;
    
  };

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false; 

  
  environment.systemPackages = with pkgs; [
    vim
    git
    tmux
    wget
    curl
    htop
    bash-completion
    python3
    man-pages
  ];

  system.stateVersion = "26.05"; 
}
