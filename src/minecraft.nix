# Minecraft server — clean slate. Configure for your chosen server type (vanilla, Forge, Fabric, etc.).
{ config, pkgs, ... }:

{
  services.minecraft-server = {
    enable = true;
    eula = true;
    openFirewall = true;

    dataDir = "/var/lib/minecraft";

    jvmOpts = "-Xms2G -Xmx2G -XX:+UseG1GC";

    serverProperties = {
      "server-port" = 25565;
    };
  };
}
