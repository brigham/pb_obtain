# AGENTS.md

This document provides guidance for AI agents working on this Dart project.

## TL;DR

This section contains the most important information that must be followed.

### Precommit

Before submitting changes, ALWAYS run `bin/precommit.sh` to:

- Update build_runner generated files.
- Format and fix files.
- Update code coverage stats.

If the script identifies a code coverage regression, it will list the affected paths. In that case, use COVERAGE.csv to
identify which tests have regressed.

Always commit the updated COVERAGE.csv file as part of your changes.

## Introduction

This is a Dart project for downloading and running releases of PocketBase.

## Development Workflow

### PocketBase Server (`bin/start_pocketbase.dart`)

The `bin/start_pocketbase.dart` script can be used to start the PocketBase server independently.

The agent_setup.sh script has placed the pocketbase binary at $HOME/develop/pocketbase/pocketbase, which
is the default for the script.

* **Persistent Data:** To start the server with a persistent database, provide a directory path:
  ```bash
  dart run bin/launch.dart --config PB_CONFIG --output .pocketbase_data
  ```
* **Temporary Data:** To start the server with a temporary database directory, run the script without any arguments:
  ```bash
  dart run bin/launch.dart --config PB_CONFIG
  ```

### Code Style

The project uses `lints` to enforce a consistent code style.
