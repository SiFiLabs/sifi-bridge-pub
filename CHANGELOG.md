# Change Log

This file summarizes the changes of every SiFi Bridge release.

## [2.0.0] - 2026-XX-XX

This release is made jointly with the release of the next generation SiFi devices with expanded configuration capabilities. Refer to the revamped User Guide for in-depth documentation about the new features and possible configurations.

The most important user-facing changes are the new [Data Packet structure](#new-packet-structure-ppg).

### Added

- Added support for changing sensor sampling rates. Please be wary of the limitations as described in the docs
- Added new IMU configurations to REPL, refer to docs for details
- Added new PPG configurations to REPL, refer to docs for details
- Added mains notch and DC notch filtering to ECG, EMG and EDA/BIOZ
- Added "timestamps" key to packets, which contain the unix epoch timestamp of each sample. Timestamps are calculated from the **number of samples of the channel** and **its configured sampling rate**, **not** the on-the-fly `sampling_rate` packet value
- Added DFU to REPL options, although the current implementation pollutes stdout
- Added support for automatic reconfiguration from StartPacket
- Added `> download-memory` to REPL for a more streamlined interface to download a device's memory to CSV
- Added `> command identify-hardware` to fetch hardware configuration from device. Only internally useful
- Added `> configure stealth-mode` to disable the LEDs during acquisition for specific use cases
- Added `> configure motor-intensity` to set the desired vibration motor intensity
- Added `> configure adc-gain` to configure the ECG and EMG ADC gain either in high resolution mode or high dynamic range mode
- Added `> firmware-update` DFU capability within the REPL, although the current integration is still under development for robustness
- Added support for device events, which are currently either (a) button press or (b) software event (see [this section](#events))
- Added `> event` to generate a "Software Event"
- Added `"start_time"` key to Start Time packet. It contains the acquisition start time as a unix epoch timestamp, used internally as the acquisition's timebase

### Changed

- Changed the prompt from `>>>` to `>`
- Removed "Max" from BleTxPower options
- PPG now always delivers packets with each channel of equal length
- Renamed `> configure channels` to `> configure sensors` for consistency
- All sensor configurations are now optional. Omitting a parameter will leave it as-is. This allows much better future extensibility
- Devices automatically reconfigure themselves from the parameters sent by the device, for example at the start of an acquisition or Identify Hardware packet
- Deprecated `> serial` due to the new `> download-memory` command
- Removed `--all` flags from `> start; stop; event` commands, as they added unnecessary complexity and it is expected that frontends will keep track of created devices anyways
- Renamed `"devices"` field from `> start; stop; event` commands to `"id"` to be in-line with the other packets' schema
- Renamed `"data_lost_count"` Data Packet key to `"samples_lost"`

### Fixed

- Fixed PPG conversion factors and added real-time update of PPG parameters
- Memory download sample timestamps are now valid
- Varia robustness fixes, especially in BLE handling

### New packet structure (PPG)

```json
{
  "device": "BioPointV1_3",
  "id": "default-1",
  "mac": "00:11:22:33:44:55:66",
  "packet_type": "ppg",
  "data": {
    "g": [
      8133.8832600000005,
      ...,
      8133.742590000001
    ],
    "b": [
      8066.9243400000005,
      ...,
      8067.768360000001
    ],
    "r": [
      8057.780790000001,
      ...,
      8057.5776000000005
    ],
    "ir": [
      8075.4739500000005,
      ...,
      8074.629930000001
    ]
  },
  "timestamps": [
    1758673309.48,
    ...,
    1758673310.2
  ],
  "samples_lost": 0,
  "sample_rate": 42.39877719866005,
  "status": "ok",
  "timestamp": 1758673310.618
}
```

### Events

Events are externally generated, currently either via button or software (BLE command). They can be used in live trials to mark something in time in sync with other sensors. They are treated much like other sensors.

The following event types are defined, and are encoded with the packet's `data` field. The timestamp is the time at which the event occured, just like all other sensors.

- 0: null event (should never occur)
- 1: button event
- 2: software event

```json

 {
  "device": "BioPointV1_3",
  "id": "default-1",
  "mac": "00:11:22:33:44:55:66",
  "packet_type": "event",
  "data": {
    "event": [1],
  },
  "data_timestamps": {
    "event": [1758673309.48],
  },
  "data_lost_count": {
    "event": 0,
  },
  "sample_rate": 0,
  "status": "ok",
  "timestamp": 1758673310.618
} 
```

## [1.4.0] - 2025-07-20

This release adds a new command to the REPL to download to CSV and makes the BLE handling more robust.

### Added

- `download-memory` command in the REPL to download the device's onboard memory to CSV files. Supports BLE and serial download.

### Fixed

- Improved the robustness of BLE handling

## [1.3.4] - 2025-04-02

This release allows Linux users to select a specific bluetooth adapter. This feature has only been tested on a Ubuntu system using `bluez`.

### Added

- **Linux only**: setting the `SIFIBRIDGE_BLE_ADAPTER` environment variable to a bluetooth adapter (e.g., `hci0`) will make sifibridge prioritize using that adapter, falling back to the first found adapter otherwise.
- Added support for serial download to CSV

### Fixed

- Improved the robustness of CSV publisher

## [1.3.3] - 2025-03-14

This release changes the Linux compilation runner.

### Changed

- Changed GitHub runner from `ubuntu-latest` to `ubuntu-22.04` for compatibility

## [1.3.2] - 2025-02-11

This release allows to connect to arbitrarily-named SifiBands and BioPoints.

### Added

- `show` shows the MAC address.
  
### Changed

- Bridge is able to connect and detect the device type for any Sifiband/BioPoint versions.

### Fixed

- Fixed temperature packets not being generated with SiFiBand
- Fixed an issue with Sifiband type detection
  
### Known issues

- To monitor: whether the missing printed messages issue is 100% fixed.
- M2/M3-based Macs seem to have much lower BLE throughput than expected, leading to lost data (`lost_data_count` key of packets).
- Some computers seem to have high latency when restarting `sifibridge`.

## [1.3.1] - 2025-02-02

This release implements some security fixes.

### Added

- Upon startup and when `connect`ing or `list ble`ing, an error message is sent to `stderr` if BLE is off.

### Changed

### Fixed

- Fixed the  error message returned when `select`ing an inexisting device.
- Added checks to ensure a connection cannot be stolen (e.g., `connect BioPoint_v1_3; new device2; connect BioPoint_v1_3`).
- Fixed a bug where without `-p`, some response messages would not be printed on screen.
- Archer TX50E (Intel chipset) SiFiBand connection issues were fixed with a SiFiBand firmware update.
  
### Known issues

- To monitor: whether the missing printed messages is 100% fixed.
- M2/M3-based Macs seem to have much lower BLE throughput than expected, leading to lost data (`lost_data_count` key of packets).
- Some computers seem to have high latency when restarting `sifibridge`.

## [1.3.0] - 2024-12-15

This release adds many new features to SiFi Bridge, a built-in Lua plugin system, DFU, shell completion script generation, verbose flags. It also contains some formatting changes made for consistency and robustness.

### Added

- Lua plugins are now supported in the REPL with `>>> plugin -[source] path/to/plugin.lua`. They apply to the _active_ device only and can receive data either from biosensors (EMG, ECG, etc.) or from other plugins.
- ̀`sifibridge completion <SHELL>` commands to generate CLI autocompletion scripts.
- `sifibridge ble upgrade [...]` command to upgrade a device's firmware.
- `-v[...]` verbose flag added to show internal logs.
- Added a "connected" field to `>>> show`.
- Added progress indicators for the `sifibridge ble analyze` suite of commands
- Temperature values are now treated as a first-class BioSensor, meaning it can be used with all publishers and plugins.

### Changed

- A "new" response is sent upon startup, in response to sifibridge creating a default device.
- Responses are now sent with a more robust format: `{"response_type": {<payload as before>}}`.
- Battery field in status packet renamed to `"battery_%"`.
- `>>> show` now includes more information, such as `"battery_%"` and `"memory_used_kbytes"`.
- BioArmband has been renamed to SiFiBand.
- Timestamps now use the local time instead of UTC.
- All serialization is now in snake_case, **except** the device type field (BioPointV1_3, SiFiBand)
- PPG values are now scaled in nA instead of pA

### Fixed

- CSV publisher now handles multiple devices properly
- Fixed a regression with BioPoint_v1_0
  
### Known issues

- Archer TX50E Bluetooth adapter currently does not work with BioArmband since a recent driver update (tested on PopOs 22.04 and Windows 11).
- M2/M3-based Macs seem to have high latency with SiFiBand.
- Some computers seem to have high latency when restarting `sifibridge`.

## [1.2.1] - 2024-11-14

### Added

### Changed

### Fixed

- Connect by UUID/MAC now works again.

### Known issues

Archer TX50E Bluetooth adapter currently does not work with BioArmband since a recent driver update (tested on PopOs 22.04 and Windows 11).

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
