{ pkgs, ... }:
{
  programs.zsh.enable = true;

  users.users.james = {
    isNormalUser = true;
    description = "James Nguyen";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      fastfetch
      hyfetch
      ufetch
      pfetch
    ];
  };
}
