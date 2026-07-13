# Getting started

This page describes the recommended first steps for using `ATCmd.au3` with a modem that accepts AT commands.

## Prerequisites

- AutoIt 3.3.14.5 or newer, matching the version noted in the UDF header.
- `ATCmd.au3` available in your script include path or next to your script.
- `ComUDF.au3` available next to `ATCmd.au3` or in a location that AutoIt can include.
- A modem exposed as a serial COM port.
- A SIM card, if you want to test network registration or SMS functions.

## Basic workflow

1. Connect the modem to the machine.
2. Confirm that the operating system exposes the device as a COM port.
3. Include `ATCmd.au3` in your AutoIt script.
4. Use `_ATCmd_ListDevices()` to inspect available modem-related ports.
5. Use `_ATCmd_Connect()` with the COM port or device name.
6. Use `_ATCmd_CommandSyncOK('AT')` as a basic communication test.
7. Use `_ATCmd_GetAllStatus()` to inspect modem, SIM, PIN, network, and sender support status.
8. Use `_ATCmd_Disconnect()` when finished.

## Minimal conceptual example

```autoit
#include "ATCmd.au3"

; Example flow only. Adjust COM port/device name and PIN handling for your environment.
Local $sDevice = "COM3"
Local $iResult = _ATCmd_Connect($sDevice)
If @error Then
    ConsoleWrite("Connect failed: " & _ATCmd_GetLastErrorMessageCR() & @CRLF)
    Exit
EndIf

Local $sResponse = _ATCmd_CommandSyncOK("AT")
ConsoleWrite($sResponse & @CRLF)

_ATCmd_Disconnect()
```

## Notes

- Do not send SMS commands before validating modem communication and SIM/PIN status.
- For SMS testing, start with a dedicated test SIM and a controlled recipient number.
- Some modems require vendor-specific drivers before a COM port appears.
