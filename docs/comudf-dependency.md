# ComUDF dependency

`ATCmd.au3` depends on `ComUDF.au3` for serial-port communication.

The main UDF includes `ComUDF.au3` directly:

```autoit
#include "ComUDF.au3"
```

## Why this dependency exists

AT-command modems are usually exposed to Windows as serial COM devices. `ATCmd.au3` focuses on modem-level operations and SMS-related logic, while `ComUDF.au3` provides lower-level COM-port operations such as opening the port, sending strings or characters, reading responses, and closing the connection.

## Practical consequence

When distributing or testing `ATCmd.au3`, keep `ComUDF.au3` together with it unless your project already has a reliable include path that resolves `ComUDF.au3`.

Recommended layout for examples and local tests:

```text
project/
  ATCmd.au3
  ComUDF.au3
  Examples/
    Example_*.au3
```

## Documentation recommendation

Examples should mention the dependency explicitly, especially when a user copies only `ATCmd.au3` into a new test directory. Missing `ComUDF.au3` is expected to fail at include/compile time before any modem communication starts.
