# ATCmd.au3 documentation

This directory contains project-level documentation for `ATCmd.au3`.

`ATCmd.au3` is an AutoIt UDF for controlling AT-command modems, including basic modem communication, SIM/PIN checks, SMS sending, and SMS listing.

## Documentation map

- [Getting started](getting-started.md) - minimal setup flow and first modem checks.
- [ComUDF dependency](comudf-dependency.md) - why `ComUDF.au3` is required and what it provides.
- [Modem testing](modem-testing.md) - suggested manual testing sequence for real devices.
- [API overview](api-overview.md) - public functions grouped by purpose.
- [Troubleshooting](troubleshooting.md) - common connection, timeout, SIM, PIN, and SMS issues.
- [Reference links](links.md) - forum topics and AT-command reference material.

## Scope

The files in this directory are documentation only. They do not change the runtime behavior of the UDF.

## Related project files

- `ATCmd.au3` - main UDF file.
- `ComUDF.au3` - serial/COM-port dependency used by `ATCmd.au3`.
- `README.md` - short repository-level summary.
