# 0.7.9

* Use advisory file locking in `obtain()` to prevent cross-process races during
  binary download and extraction.

# 0.7.8

* Add support for automatic free port identification by setting `port: 0` in
  `LaunchConfig`.
* Expose `httpHost` in `PocketBaseProcess` to programmatically discover the
  assigned port.
* Update `json_serializable` dependency and move it to `dev_dependencies`.

# 0.7.7

* Require newer version of json_serializable.

# 0.7.6

* Add programmatic usage section to README.md.

# 0.7.5

* Add missing generics.

# 0.7.4

* Can now enable --dev flag when launching.

# 0.7.3

* Fix bug with relative executable paths.

# 0.7.2

* Add stdout and stderr redirection.

# 0.7.1

* Fixed some bugs with mutually exclusive fields.

# 0.7.0

* Use `checked_yaml` for better error messages.

# 0.6.0

* Rename start.dart to launch.dart.
* Reusable YAML and CLI argument parsing.

# 0.5.0

* `launch` returns `PocketBaseProcess` and waits for a valid health
  check before returning.
* `launch` will obtain if needed, as implied by the config interface.
* Clean up dependencies.

# 0.4.0+1

* Export the code this time.

# 0.4.0

* Fork from `pb_dtos`, removing unrelated code.
* Clean up naming.

