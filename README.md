# pb_obtain

Download (and run) a specific PocketBase release for tests or whenever
it may come in handy.

## Experimental

This package is experimental and will have significant cleanup
around the YAML and command line flags.

I'm expecting to get to 1.0 quickly after those are sorted out.

## Getting Started

Choose a directory (`RELEASE_DIRECTORY`) where you will store the downloaded binaries.

Optional: create a directory (`POCKETBASE_CONFIG`) to store your 
migrations and hooks that will be used to start up PocketBase.

You can either create a YAML file for reusable config or just use
the command line flags.

```yaml
# PocketBase DTO Generator Configuration
version: RELEASE_VERSION
release-directory: RELEASE_DIRECTORY
config: POCKETBASE_CONFIG
port: PORT
```

Add this package as a dependency.

```shell
$ dart pub add dev:pb_obtain
```

Run `dart run pb_obtain:start_pocketbase`. You should run this command
when you update your migrations or when you upgrade this package.
