{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ "${modulesPath}/virtualisation/amazon-image.nix" ];

  environment.systemPackages = with pkgs; [
    vim
    git
    tmux
    python3
  ];

  system.stateVersion = "25.05";
}
