# Troubleshooting

This page lists common failure areas when testing `ATCmd.au3` with real AT-command modems.

## COM port is not found

Possible causes:

- modem driver is missing,
- modem is not exposed as a serial COM port,
- another application is already using the COM port,
- the wrong device interface was selected,
- the modem exposes multiple COM ports and only one accepts AT commands.

Recommended checks:

- inspect Windows Device Manager,
- run `_ATCmd_ListDevices()`,
- close vendor modem tools before testing,
- test each modem-related COM port with a simple `AT` command.

## `_ATCmd_Connect()` fails

Possible causes:

- invalid COM port or device name,
- missing `ComUDF.au3`,
- access denied to the COM port,
- unsupported serial settings for the modem,
- disconnected or suspended USB modem.

Recommended checks:

- confirm that `ComUDF.au3` is present,
- reconnect the modem,
- test with another USB port,
- verify that no other process keeps the port open.

## Command timeout

Possible causes:

- modem did not answer,
- command was sent to the wrong COM interface,
- timeout is too short for this modem,
- modem is busy registering to network,
- modem expects a different command mode.

Recommended checks:

- start with `_ATCmd_CommandSyncOK('AT')`,
- increase wait time for slow operations,
- check signal and network registration status,
- inspect the raw modem response when possible.

## SIM or PIN errors

Possible causes:

- SIM card missing,
- SIM card not ready,
- PIN required,
- wrong PIN,
- SIM blocked or PUK required,
- operator/network registration problem.

Recommended checks:

- run `_ATCmd_IsSIMInserted()`,
- run `_ATCmd_IsPINRequired()`,
- run `_ATCmd_IsPINReady()`,
- use `_ATCmd_GetAllStatus()` before SMS tests.

## SMS sending fails

Possible causes:

- modem is not registered to network,
- SMS center configuration is missing or invalid,
- sender mode is unsupported,
- PDU/text mode mismatch,
- UCS2/non-ASCII message encoding issue,
- insufficient SIM balance or blocked outgoing SMS.

Recommended checks:

- send a simple ASCII-only test message first,
- verify SMS listing before sending,
- test both PDU/text-related settings where appropriate,
- validate UCS2 behavior separately for non-ASCII messages.

## Development logging

For development tests, keep logs verbose enough to diagnose AT command/response flow, but do not publish private data such as phone numbers, IMSI/ICCID identifiers, or operator-specific account details.
