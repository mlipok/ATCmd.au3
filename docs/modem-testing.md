# Modem testing

This page proposes a conservative manual testing order for `ATCmd.au3`.

## Test environment checklist

Before running SMS-related tests, confirm:

- the modem is visible as a COM port,
- the modem driver is installed,
- the SIM card is inserted,
- the SIM card is active,
- PIN handling is understood for the test device,
- the test SIM has enough credit or an active SMS plan,
- the target phone number is controlled by the tester.

## Suggested test sequence

1. **Device discovery**
   - Run `_ATCmd_ListDevices()`.
   - Confirm that the expected modem or COM port is visible.

2. **Connection test**
   - Run `_ATCmd_Connect()`.
   - If a PIN is required, pass the PIN only in a controlled local test script.

3. **Basic AT command test**
   - Run `_ATCmd_CommandSyncOK('AT')`.
   - Expected result: the modem responds with `OK`.

4. **SIM and PIN status**
   - Run `_ATCmd_IsSIMInserted()`.
   - Run `_ATCmd_IsPINRequired()`.
   - Run `_ATCmd_IsPINReady()`.

5. **Status overview**
   - Run `_ATCmd_GetAllStatus()`.
   - Confirm manufacturer, model, SIM status, network registration, signal strength, and sender support where available.

6. **SMS listing**
   - Run `_ATCmd_SMS_ListMessages()` before sending new messages.
   - This helps confirm storage mode and response parsing.

7. **SMS sending**
   - Test with one controlled recipient number.
   - Keep message content simple for the first test.
   - Then test UCS2/non-ASCII content if needed.

## Safety notes

- Avoid automated SMS loops during early testing.
- Keep timeouts conservative while validating a new modem.
- Log full command/response data during development, but avoid committing private phone numbers, SIM identifiers, or operator-specific details.
