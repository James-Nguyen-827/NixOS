# Craft to Exile 2 — CurseForge 1.20.1 Forge modpack server (6GB RAM).
# Download the server pack from CurseForge and extract it to the data directory
# before starting: https://www.curseforge.com/minecraft/modpacks/craft-to-exile-2/files
# Look for "Craft to Exile 2 SERVER-1.1.3.zip" (or latest SERVER-*.zip), extract
# into /var/lib/craft-to-exile-2, accept EULA if prompted, then start the service.
{ config, pkgs, ... }:

let
  dataDir = "/var/lib/craft-to-exile-2";
  # JVM heap: at least 6GB as requested
  jvmOpts = "-Xms6G -Xmx6G -XX:+UseG1GC";
  startScript = pkgs.writeShellScript "craft-to-exile-2-start" ''
    set -e
    cd "${dataDir}"
    if [ ! -f run.sh ] && [ ! -f run.bat ]; then
      echo "Craft to Exile 2 server pack not found in ${dataDir}."
      echo "Download 'Craft to Exile 2 SERVER-*.zip' from CurseForge and extract it here."
      exit 1
    fi
    export JAVA_TOOL_OPTIONS="${jvmOpts}"
    exec ${pkgs.bash}/bin/bash ./run.sh
  '';
in
{
  # Disable vanilla minecraft-server; we use a custom service for the modpack
  services.minecraft-server.enable = false;

  networking.firewall.allowedTCPPorts = [ 25565 ];

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
