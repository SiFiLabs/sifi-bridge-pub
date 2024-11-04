# Change Log

This file summarizes the changes of every SiFi Bridge release.

## [1.2.0] - 2024-10-14

This release adds a new cli commands to Bridge, new data output formats as well as some fairly major internal changes, resulting in a better overall experience.

### Added

- `--csv-out` to save data packets into csv files, which are created by Bridge itself and named with the following template: `<device-name>_<yyyy-mm-dd-hh-mm-ss>_<channel>.csv`
- `--udp-out` to send data packets to a specified UDP socket.
- Added the `sifibridge ble analyze` subcommand to analyze some aspects of SiFi devices at runtime.

### Changed

- SiFi Bridge output now differentiates between _input responses_ and _data packets_. _Input responses_ are always sent to the **same transport** as the input transport, while _Data packets_ are only sent to the **output transport** (eg CSV, UDP, etc.).
- The concept of _managers_ has been reverted back to _devices_ for clarity.
- `--tcp-out` **no longer binds a port**. Now, `sifibridge` connects as a **client** to the specified IP address.
- The LSL integration has been majorly reworked, now supporting dynamic reconfiguration of streams as devices are reconfigured.
- Updated inline documentation strings.
- Status packet `memory_used_kb` has been changed to `memory_used_kbytes` for better clarity

### Fixed

### Known issues

Archer TX50E Bluetooth adapter currently does not work with BioArmband since a recent driver update (tested on PopOs 22.04 and Windows 11).

## [1.1.1] - 2024-09-19

### Fixed

- Fixed a regression which could prevent some command output from showing and increased CPU usage

## [1.1.0] - 2024-09-18

This release adds a few new cli commands to Bridge, as well as some more performance and safety features.

### Added

- `--lsl` flag to enable LSL output of **data packets**. Status packets are still delivered via the chosen output transport and so are response packets from the REPL
- `ble latency` to do a `Low Latency` packet latency test (only supported on latest BioPoints as of now)
- `ble throughput` to test the full-duty data throughput of a device
- `ble command` to send a command from the cli entry

### Changed

- Quaternions are now called `qw, qx, qy, qz` (previously `w, x, y, z`)
- Quaternions are now normalized

### Fixed

- Fixed a few minor bugs

### Known issues

Archer TX50E Bluetooth adapter currently does not work with BioArmband since a recent driver update (tested on PopOs 22.04 and Windows 11).

## [1.0.0] - 2024-08-15

Finally, SiFi Bridge is at a point where it is convenient and stable enough to be released officially as 1.0.0!

This release marks a major leap in both ease-of-use and documentation accessibility of SiFi Bridge and we would be grateful for users to open issues directly in this repo for any suggestions or bugs encountered.

### Added

- CLI entry subcommands for one-shot operations
- LabStreamingLayer integration
- REPL inline documentation
- Bridge will now send back an acknowledgement (and status) response whenever a manager command or a device command is sent

### Changed

- The old REPL commands API is completely scrapped in favor of the subcommand REPL API
- It is no longer possible to chain multiple subcommands in a single prompt
- Accelerometer data is now in m/s² (previously in g's)
- PPG data is now in lm (previously raw sensor value)

### Fixed

- Fixed a bad handling of stdin, which caused incredibly high memory consumption when Bridge was used alongside Python
- Fixed MacOS UUID and Win/Lin MAC Address which were reversed
