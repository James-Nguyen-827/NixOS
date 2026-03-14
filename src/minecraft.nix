# Minecraft server — Craft to Exile 2 (CurseForge, Forge 1.20.1).
# Modpack: https://www.curseforge.com/minecraft/modpacks/craft-to-exile-2 — 1.1.3 (server pack).
# First start installs Forge and extracts the official server pack into dataDir; later starts use existing install.
{ config, pkgs, ... }:

let
  # Forge 1.20.1 recommended installer (47.4.10). Run with --installServer to produce run.jar + libraries.
  forgeInstaller = pkgs.fetchurl {
    url = "https://maven.minecraftforge.net/net/minecraftforge/forge/1.20.1-47.4.10/forge-1.20.1-47.4.10-installer.jar";
    hash = "sha256-GRJ2C0y2uAPYqCbeYDyQdrHacewnZemh+MHKePZSeOM=";
  };

  # Official Craft to Exile 2 SERVER pack from CurseForge (file 7192879). Fetched so the repo zip need not be in Git.
  modpackZip = pkgs.fetchurl {
    url = "https://edge.forgecdn.net/files/7192/879/Craft%20to%20Exile%202%20SERVER-1.1.3.zip";
    hash = "sha256-V4/C+Kk0mU+XWQhO3aMbfJtz1IDTcMWY688ULZCeko0=";
    name = "craft-to-exile-2-server-1.1.3.zip";
  };

  # Startup script runs in dataDir. Installs Forge and extracts modpack on first run, then starts Forge server.
  java = pkgs.jdk21;
  startupScript = pkgs.writeShellScript "minecraft-server" ''
    set -e
    DATA_DIR="$(pwd)"

    # First run: install Forge server, then extract modpack overrides (mods, config, etc.)
    if [ ! -f run.jar ] && [ ! -f forge-*.jar ]; then
      echo "First run: installing Forge 1.20.1 and Craft to Exile 2 modpack..."
      cp "${forgeInstaller}" "$DATA_DIR/forge-installer.jar"
      "${java}/bin/java" -jar "$DATA_DIR/forge-installer.jar" --installServer
      rm -f "$DATA_DIR/forge-installer.jar"

      echo "Extracting modpack (mods, config, ...)..."
      "${pkgs.unzip}/bin/unzip" -o "${modpackZip}" -d "$DATA_DIR/modpack-extract"
      if [ -d "$DATA_DIR/modpack-extract/overrides" ]; then
        cp -r "$DATA_DIR/modpack-extract/overrides"/* "$DATA_DIR/"
      else
        # Server pack or flat layout: copy everything except manifest
        for d in mods config defaultconfigs kubejs; do
          [ -d "$DATA_DIR/modpack-extract/$d" ] && cp -rn "$DATA_DIR/modpack-extract/$d" "$DATA_DIR/"
        done
      fi
      rm -rf "$DATA_DIR/modpack-extract"
    fi

    if [ ! -f eula.txt ] || ! grep -q 'eula=true' eula.txt 2>/dev/null; then
      echo "eula=true" > eula.txt
    fi

    JAR=""
    [ -f run.jar ] && JAR="run.jar"
    [ -z "$JAR" ] && JAR=$(ls forge-*.jar 2>/dev/null | head -1)
    [ -z "$JAR" ] && JAR=$(ls *.jar 2>/dev/null | head -1)
    [ -z "$JAR" ] && { echo "No server jar found. Remove server directory and restart to reinstall."; exit 1; }
    exec "${java}/bin/java" "$@" -jar "$JAR" nogui
  '';

  craft-to-exile-2-server = pkgs.runCommand "minecraft-craft-to-exile-2-server" { } ''
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

    package = craft-to-exile-2-server;
    dataDir = "/var/lib/minecraft";

    # 8 GiB heap; modpack recommends 6GB+ for multiplayer. Increase for more players.
    jvmOpts = "-Xms8G -Xmx8G -XX:+UseG1GC";

    serverProperties = {
      "server-port" = 25565;
    };
  };
}
