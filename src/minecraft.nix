# Craft to Exile 2 — CurseForge 1.20.1 Forge modpack server (6GB RAM).
# Whitelist is enforced so only whitelisted players can join.
#
# Port forwarding (so friends can connect from the internet):
#   1. On your router: forward TCP 25566 → 192.168.1.67:25566.
#   2. Give friends your public IP (or a DDNS hostname) and port 25566.
#
# Adding players (required — they cannot join until whitelisted):
#   In-game (as op): /whitelist add <MinecraftUsername>
#   Or edit /var/lib/craft-to-exile-2/whitelist.json (see Minecraft wiki for format) and restart the service.
#   To op yourself first: add your user to /var/lib/craft-to-exile-2/ops.json, then restart.
{ config, pkgs, ... }:

let
  dataDir = "/var/lib/craft-to-exile-2";
  # JVM heap: at least 6GB as requested
  jvmOpts = "-Xms6G -Xmx6G -XX:+UseG1GC";
  # Enforce whitelist and custom port so only added players can join on 25566
  startScript = pkgs.writeShellScript "craft-to-exile-2-start" ''
    set -e
    cd "${dataDir}"
    if [ ! -f run.sh ] && [ ! -f run.bat ]; then
      echo "Craft to Exile 2 server pack not found in ${dataDir}."
      echo "Download 'Craft to Exile 2 SERVER-*.zip' from CurseForge and extract it here."
      exit 1
    fi
    # Ensure whitelist is on so only whitelisted players can connect
    if [ -f server.properties ]; then
      if grep -q '^white-list=' server.properties; then
        sed -i 's/^white-list=.*/white-list=true/' server.properties
      else
        echo 'white-list=true' >> server.properties
      fi
      # Force the server to listen on port 25566 instead of the default 25565
      if grep -q '^server-port=' server.properties; then
        sed -i 's/^server-port=.*/server-port=25566/' server.properties
      else
        echo 'server-port=25566' >> server.properties
      fi
    fi
    export JAVA_TOOL_OPTIONS="${jvmOpts}"
    exec ${pkgs.bash}/bin/bash ./run.sh
  '';
in
{
  # Disable vanilla minecraft-server; we use a custom service for the modpack
  services.minecraft-server.enable = false;

  # Open the custom server port in the firewall
  networking.firewall.allowedTCPPorts = [ 25566 ];

  systemd.services.craft-to-exile-2 = {
    description = "Craft to Exile 2 (CurseForge 1.20.1 Forge) server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      Restart = "on-failure";
      RestartSec = "30s";
      StateDirectory = "craft-to-exile-2";
      WorkingDirectory = dataDir;
    };

    path = [ pkgs.jdk17 ];

    script = ''
      exec ${startScript}
    '';
  };
}
