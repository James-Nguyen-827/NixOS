## Agent Instructions for This Repository

### Repository Context

- **Purpose**: This repository contains a NixOS configuration for a homelab.
- **Homelab IP**: `192.168.1.67`.
- **Access**: You (the agent) have SSH access to the homelab via the local IP.

### Build and Deploy Workflow

- **Build locally**: Run `just build` to build the current configuration.
- **Deploy remote**: Run `just deploy` to deploy the latest *remote* configuration to the homelab.

### Git and Deployment Requirements

- **Commit requirement**: Changes must be committed to the local git repository before they can be deployed.
- **Push requirement**: Changes must be pushed to the remote repository; `just deploy` uses the latest configuration from the remote.

### High-Level Behavior for Agents

- **When editing configuration files**: 
  - Make changes in the appropriate `src/*.nix` files.
  - Ensure the configuration remains valid NixOS syntax.
- **Before deployment**:
  - Verify the configuration builds successfully using `just build`.
  - Commit and push relevant changes.
- **When deploying**:
  - Use `just deploy` only after changes are pushed and you intend to update the running homelab system.
