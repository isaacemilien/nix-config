{ config, lib, pkgs, ... }:

{
  imports = [
    ../modules/common.nix
    ../hardware-configuration.nix
  ];

  networking.hostName = "ec2-nixos";
  networking.useDHCP = lib.mkDefault true;
  
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };
  
  networking.firewall.allowedTCPPorts = [ 22 ];

  services.xserver.enable = false;
}
