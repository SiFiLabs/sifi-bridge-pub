# SiFi Bridge

The public-facing SiFi Bridge repository

## Installation

### Quick Install

#### Linux/macOS

Run the following command to install the latest version:

```bash
curl -fsSL https://raw.githubusercontent.com/SiFiLabs/sifi-bridge-pub/main/scripts/install.sh | bash
```

By default, this installs to `~/.local/bin`. To install to a different directory:

```bash
curl -fsSL https://raw.githubusercontent.com/SiFiLabs/sifi-bridge-pub/main/scripts/install.sh | INSTALL_DIR=/usr/local/bin bash
```

#### Windows

Run the following command in PowerShell to install the latest version:

```powershell
irm https://raw.githubusercontent.com/SiFiLabs/sifi-bridge-pub/main/scripts/install.ps1 | iex
```

By default, this installs to `$env:LOCALAPPDATA\Programs\SiFiBridge`. To install to a different directory:

```powershell
& ([ScriptBlock]::Create((irm https://raw.githubusercontent.com/SiFiLabs/sifi-bridge-pub/main/scripts/install.ps1))) -InstallDir "C:\Path\To\Install"
```

### Manual Installation

1. Download the appropriate release for your platform from the [Releases](https://github.com/SiFiLabs/sifi-bridge-pub/releases/latest) page
2. Extract the archive (`.tar.gz` for Linux/macOS, `.zip` for Windows)
3. Move the binary to a directory in your PATH
   - Linux/macOS: `~/.local/bin` or `/usr/local/bin`
   - Windows: `%LOCALAPPDATA%\Programs\SiFiBridge` or `C:\Program Files\SiFiBridge`
4. Make it executable (Linux/macOS only): `chmod +x sifibridge`
5. Add the directory to your PATH if needed

## CLI

The SiFi Bridge CLI is currently closed-source. The official releases are exposed on this repository in the Releases tab.

For CLI usage, use `sifibridge --help` to see available options and subcommands.

For REPL usage, use `sifibridge -p` followed by `>>> help` to see the REPL commands help page.

## Python wrapper

A freely available Python wrapper is available both on [GitHub](https://github.com/SiFiLabs/sifi-bridge-py) and on [PyPI](https://pypi.org/project/sifi-bridge-py/).

## Troubleshooting

- At the first launch on MacOS devices, you may see a popup stating: "sifibridge cannot be opened because the developer cannot be verified". To fix this (MacOS Sequoia), go into System Settings -> Privacy & Security -> Scroll to "Security" -> Allow sifibridge
