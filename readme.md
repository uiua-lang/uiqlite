[![Status](https://img.shields.io/badge/status-experimental-orange)](https://github.com/uiua-lang/uiqlite)
[![License](https://img.shields.io/badge/license-MIT-blue)](LICENSE)

# Uiqlite

SQLite3 bindings for [Uiua](https://www.uiua.org/)

**⚠️ This project uses experimental features that may break with new Uiua versions.**

## Overview

Uiqlite provides native SQLite3 bindings for the Uiua programming language, enabling database operations through Uiua's array-oriented paradigm. The library wraps SQLite's C API using Uiua's FFI system and provides Uiua functions for database interactions.

## Features

- Low-level functions for interaction with SQLite databases
- Idiomatic high-level idiomatic functions to simplify the API for Uiua
- Automatic type detection and conversion between Uiua and SQLite types

## Installation

Adding Uiqlite to your project:

```uiua
Sql ~ "git: github.com/uiua-lang/uiqlite"
```

Uiqlite uses Uiua's Foreign Function Interface (FFI) system to call SQLite's C API directly, only works in native environment on supported platforms (Windows, MacOS, Linux). Does not work in the browser environment.

## Examples

See the [`examples/`](examples/) directory for complete working examples:

- [`raw_query.ua`](examples/raw_query.ua): Basic table creation and querying
- [`using_datadef.ua`](examples/using_datadef.ua): Working with query results as structured data using Uiua's data definitions
- [`prepared_insert.ua`](examples/prepared_insert.ua): Using prepared statements with positional and named parameters

## Development setup

### Testing

If you add new functionality or fix a bug, please add the appropriate tests to the `test.ua` file.

Use this command to run the test suite:

```bash
uiua run test.ua
```

If the script runs without errors - everything _should_ be working as expected. 

### Building SQLite3

A build script is included to compile SQLite for all supported platforms. Uiua's module system clones this whole repository which makes those binaries reliably available to the library users.

Run this command to rebuild the library:
```bash
bin/build.sh
```

The script was only tested on Linux, but it should work on Windows via WSL.

