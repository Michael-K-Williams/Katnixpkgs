{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.gx52;
in {
  options.programs.gx52 = {
    enable = mkEnableOption "GX52 application with USB support";
    
    users = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Users to grant USB access to GX52 devices";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.my-packages.gx52
    ];

    # Create plugdev group if it doesn't exist
    users.groups.plugdev = {};

    # Add specified users to plugdev group
    users.users = mkMerge (map (user: {
      ${user}.extraGroups = [ "plugdev" ];
    }) cfg.users);

    # Add udev rules for GX52 USB access
    services.udev.extraRules = ''
      # GX52 USB device rules
      SUBSYSTEM=="usb", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c07d", MODE="0664", GROUP="plugdev"
    '';
  };
}