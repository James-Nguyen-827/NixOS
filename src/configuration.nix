{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./user.nix
    ./ssh.nix
    ./minecraft.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [ "@wheel" ];
  };

  networking.networkmanager.enable = true;

  security.sudo.wheelNeedsPassword = false;
  
  time.timeZone = "America/Los_Angeles";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.hardware.openrgb.enable = true;

  environment.systemPackages = with pkgs; [
    wget
    git
    jq
    python3
    openrgb
  ];

  # Set all RGB devices to off (black) after boot when devices are available
  systemd.services.openrgb-set-black = {
    description = "Set all OpenRGB devices to black/off";
    after = [ "multi-user.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      sleep 5
      ${pkgs.openrgb}/bin/openrgb --noautoconnect -m static -c 000000 2>/dev/null || true
    '';
  };

  system.stateVersion = "25.11";
  nixpkgs.hostPlatform = {
    system = "x86_64-linux";
  };
}
