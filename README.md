# Decky Nix

This is a Flake library for easily building Decky plugins using Nix.

## Purpose

1. Provide a stable interface for creating and building Decky plugins
2. Provide a reliable infrastructure for distributing Decky plugins (for phase 2)
3. Allow plugins to share common dependencies when applicable, eliminating the need for vendoring dependencies entirely and saving disk space on the Steam Deck itself (someday)

## Testing

This project includes a demo Python project built with Poetry for testing purposes. Running `nix build .#checks.x86_64-linux.test` should result in a directory named `result` with the following structure:

```
default/
├─ lib/
├─ vendor/
main.py
plugin.json
```
