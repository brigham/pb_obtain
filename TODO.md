# Plans

To get to 1.0.0, we need the following.

## Documentation

Document the config types and `launch` and `obtain`.

## Tests

Tests that don't hit the GitHub servers repeatedly.

## Startup monitoring

Users shouldn't have to write special code to make sure the server has started.

This library should ping the health API until start up is finished.

## Shutdown assurance

Users shouldn't have to write special code to make sure the server has actually shutdown.

This library should ping the health API until shutdown occurs.
