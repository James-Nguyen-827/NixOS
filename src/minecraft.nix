# Minecraft server — COBBLEVERSE (Pokémon Adventure [Cobblemon]) modpack.
# Modpack: https://modrinth.com/modpack/cobbleverse — Fabric 1.21.1.
# First start installs the modpack via mrpack-install (~150MB download); later starts use existing install.
# To switch back to vanilla: set package = pkgs.minecraftServers.vanilla, declarative = true, and remove mods in dataDir.
{ config, pkgs, ... }:

let
  # mrpack-install: deploys Modrinth modpacks (Fabric + mods) into a server directory.
  mrpack-install = pkgs.buildGoModule rec {
    pname = "mrpack-install";
    version = "0.18.2";
    src = pkgs.fetchFromGitHub {
      owner = "nothub";
      repo = "mrpack-install";
      rev = "v${version}-beta";
      hash = "sha256-g0AfC9RRyXfhUDI5oCCFjHvkbUFgmqKyrVnMJ7jiPkM=";
    };
    vendorHash = "sha256-4FKt/IcmI1ev/eHzQpicWkYWAh8axUgDL7QxXRioTnc=";
    doCheck = false;  # Tests require network (maven.quiltmc.org)
  };

  # Startup script runs in dataDir. Installs modpack on first run, then starts Fabric server.
  startupScript = pkgs.writeShellScript "minecraft-server" ''
    set -e
    if [ ! -f server.jar ] && [ ! -f fabric-server-launch.jar ]; then
      echo "First run: installing COBBLEVERSE modpack (this may take a few minutes)..."
      "${mrpack-install}/bin/mrpack-install" Jkb29YJU 1.7.2 --server-dir "$(pwd)" -v
    fi
    if [ ! -f eula.txt ] || ! grep -q 'eula=true' eula.txt 2>/dev/null; then
      echo "eula=true" > eula.txt
    fi
    JAR=""
    [ -f fabric-server-launch.jar ] && JAR="fabric-server-launch.jar"
    [ -z "$JAR" ] && [ -f server.jar ] && JAR="server.jar"
    [ -z "$JAR" ] && JAR=$(ls *.jar 2>/dev/null | head -1)
    [ -z "$JAR" ] && { echo "No server jar found. Remove server directory and restart to reinstall."; exit 1; }
    exec java "$@" -jar "$JAR" nogui
  '';

  cobbleverse-server = pkgs.runCommand "minecraft-cobbleverse-server" { } ''
    mkdir -p $out/bin
    cp ${startupScript} $out/bin/minecraft-server
    chmod +x $out/bin/minecraft-server
  '';
in
{
  services.minecraft-server = {
    enable = true;
    eula = true;
    openFirewall = true;
    declarative = false;  # Modpack manages server.properties and config

    package = cobbleverse-server;
    dataDir = "/var/lib/minecraft";

    # 12 GiB heap for ~25 players (32 GB host). Modpack recommends 6GB+ for multiplayer.
    jvmOpts = "-Xms12G -Xmx12G -XX:+UseG1GC";

    # Only applied when declarative = true; kept for reference. Edit server.properties in dataDir if needed.
    serverProperties = {
      "server-port" = 25565;
    };
  };
}
