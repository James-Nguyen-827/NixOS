# Minecraft (Java) server — vanilla.
# Version: latest vanilla in nixpkgs = 1.21.x. To pin: e.g.
#   package = pkgs.minecraftServers.vanilla-1-20;  # 1.20.6
# For plugins/better performance: package = pkgs.papermc;
{ config, pkgs, ... }:

{
  services.minecraft-server = {
    enable = true;
    eula = true;
    openFirewall = true;
    declarative = true;

    # 12 GiB heap for ~25 players (32 GB host). G1GC is good for large heaps.
    jvmOpts = "-Xms12G -Xmx12G -XX:+UseG1GC";

    serverProperties = {
      motd = "NixOS Homelab Minecraft";
      max-players = 25;
      difficulty = 2;   # 0=peaceful, 1=easy, 2=normal, 3=hard
      gamemode = 0;    # 0=survival, 1=creative, 2=adventure, 3=spectator
      "online-mode" = true;
      "server-port" = 25565;
      "white-list" = false;
    };

    # Optional: uncomment and add UUIDs to whitelist (get UUID from https://mcuuid.net/)
    # whitelist = {
    #   "YourUsername" = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";
    # };
  };
}
