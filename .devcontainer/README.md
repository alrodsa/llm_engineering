# Guide to Configure and Open the Devcontainer (CPU/GPU)

This repository separates host detection (CPU/GPU) from devcontainer profile selection.
The idea is to select the profile first, then open or rebuild the container.

## Recommended Flow (Step by Step)

1. Open the project in VS Code (on the host, not inside the container).
2. From your local host shell/VS Code session (not inside the devcontainer), select the profile using one of these options (choose one):
	- Option A (VS Code task): `Tasks: Run Task` -> `🧰 Autoselect Container Profile`
	- Option B (terminal): `bash .devcontainer/prepare-devcontainer.sh`
3. The script detects whether your host has an NVIDIA GPU and whether Docker exposes the NVIDIA runtime.
4. Based on that result, it activates the correct profile in `.devcontainer/devcontainer.json`.
5. Open the container from VS Code:
	- `Dev Containers: Reopen in Container`

## Quick Option: Select Profile + Rebuild

From your local host (outside the devcontainer), you can run this VS Code task:

- `🚀 Autoselect Container Profile + Rebuild`

This task calls:

- `bash .devcontainer/prepare-devcontainer.sh --rebuild`

Note: CLI rebuild requires `devcontainer` to be installed on the host.

## Recommended Initial Setup

1. Check local variables in `.devcontainer/variables/.env`.
2. If it does not exist, copy the template:

```bash
cp .devcontainer/variables/example.env .devcontainer/variables/.env
```

3. Adjust values for your environment.

## Useful Manual Commands

Run these commands on the local host terminal (outside the devcontainer):

- Auto-detect: `bash .devcontainer/scripts/bootstrap-devcontainer.sh --auto`
- Force CPU: `bash .devcontainer/scripts/bootstrap-devcontainer.sh --cpu`
- Force NVIDIA: `bash .devcontainer/scripts/bootstrap-devcontainer.sh --nvidia`
- Preview without applying: `bash .devcontainer/scripts/bootstrap-devcontainer.sh --auto --dry-run`
- Auto + CLI rebuild: `bash .devcontainer/scripts/bootstrap-devcontainer.sh --auto --rebuild`

## Key Files

- `.devcontainer/devcontainer.json`: active profile (generated file)
- `.devcontainer/profiles/devcontainer.cpu.json`: CPU profile
- `.devcontainer/profiles/devcontainer.gpu.json`: GPU profile
- `.devcontainer/containers/cpu.Dockerfile`: CPU base image
- `.devcontainer/containers/gpu.Dockerfile`: GPU base image
- `.devcontainer/variables/.host-gpu.env`: host detection output

Do not edit `.devcontainer/devcontainer.json` manually; it is updated by the profile selection script.

## Common Issues

- If you have an NVIDIA GPU but it falls back to CPU, NVIDIA Container Toolkit is usually missing or Docker is not exposing the NVIDIA runtime.
- In that case, install/configure NVIDIA Container Toolkit on the host, then run `🧰 Autoselect Container Profile` again.
