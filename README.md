# SiFi Bridge

The public-facing SiFi Bridge repository

## Installation

### Quick Install

Run the following command to install the latest version:

```bash
curl -fsSL https://raw.githubusercontent.com/SiFiLabs/sifi-bridge-pub/main/scripts/install.sh | bash
```

By default, this installs to `~/.local/bin`. To install to a different directory:

```bash
curl -fsSL https://raw.githubusercontent.com/SiFiLabs/sifi-bridge-pub/main/scripts/install.sh | INSTALL_DIR=/usr/local/bin bash
```

### Manual Installation

1. Download the appropriate release for your platform from the [Releases](https://github.com/SiFiLabs/sifi-bridge-pub/releases/latest) page
2. Extract the archive
3. Move the binary to a directory in your PATH (e.g., `~/.local/bin` or `/usr/local/bin`)
4. Make it executable: `chmod +x sifibridge`

## CLI

The SiFi Bridge CLI is currently closed-source. The official releases are exposed on this repository in the Releases tab.

For CLI usage, use `sifibridge --help` to see available options and subcommands.

For REPL usage, use `sifibridge -p` followed by `>>> help` to see the REPL commands help page.

## Python wrapper

A freely available Python wrapper is available both on [GitHub](https://github.com/SiFiLabs/sifi-bridge-py) and on [PyPI](https://pypi.org/project/sifi-bridge-py/).

## Troubleshooting

- At the first launch on MacOS devices, you may see a popup stating: "sifibridge cannot be opened because the developer cannot be verified". To fix this (MacOS Sequoia), go into System Settings -> Privacy & Security -> Scroll to "Security" -> Allow sifibridge
