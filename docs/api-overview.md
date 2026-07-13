# API overview

This page groups the public `ATCmd.au3` functions by purpose.

## Connection and device discovery

- `_ATCmd_ListDevices()` - lists available devices/ports that can be used to locate the modem.
- `_ATCmd_Connect()` - connects to a COM device by COM index or device name.
- `_ATCmd_Disconnect()` - disconnects from the current modem/COM device.

## Generic AT command execution

- `_ATCmd_Command()` - sends a raw AT command string.
- `_ATCmd_CommandSync()` - sends a command and waits for a response.
- `_ATCmd_CommandSyncOK()` - sends a command and waits for an `OK` response.

## SIM and PIN handling

- `_ATCmd_IsSIMInserted()` - checks whether a SIM card is inserted.
- `_ATCmd_IsPINRequired()` - checks whether a PIN is required.
- `_ATCmd_IsPINReady()` - checks whether PIN state is ready.
- `_ATCmd_SetPIN()` - sends a PIN to the modem/SIM.
- `_ATCmd_OnPINRequest()` - handles PIN request logic.

## Modem and network status

- `_ATCmd_GetAllStatus()` - returns a broader status snapshot, including modem, SIM, network, signal, and sender-related information.
- `_ATCmd_IsSenderSupported()` - checks SMS sender support where applicable.

## SMS support

- `_ATCmd_SMS_ListMessages()` - lists SMS messages from the modem/SIM storage.
- `_ATCmd_SMS_Sender()` - sends an SMS message.
- `_ATCmd_UsePDU()` - configures PDU mode behavior.
- `_ATCmd_UseUCS2()` - configures UCS2 behavior for text encoding support.

## Error and diagnostics

- `_ATCmd_ErrorLog()` - writes diagnostic information.
- `_ATCmd_GetLastErrorMessage()` - returns the last error message.
- `_ATCmd_GetLastErrorMessageCR()` - returns the last error message with line-break formatting.

## Internal functions

Functions prefixed with double underscore, for example `__ATCmd_WaitResponse()` or `__ATCmd_ComposePDU()`, are internal implementation details and should not be treated as public API.
