# Contributing

Contributions are welcome — bug reports, fixes, support for additional platforms, and documentation improvements are all appreciated.

## Reporting issues

Before opening an issue, please:

1. Check the [Troubleshooting](README.md#troubleshooting) section of the README.
2. Search [existing issues](https://github.com/franjo124/iphone-backup/issues) to avoid duplicates.

When opening an issue, include:

- Your Linux distribution and version (`lsb_release -a`)
- Python version (`python3 --version`)
- pymobiledevice3 version (`pipx list | grep pymobiledevice3`)
- iOS version of the device
- The full terminal output of the failing command

## Making changes

1. Fork the repository and create a branch from `master`:

   ```bash
   git checkout -b fix/your-description
   ```

2. Make your changes. Keep commits focused — one logical change per commit.

3. Test your changes against a real device if possible. At minimum, verify:
   - Device detection works (`pymobiledevice3 usbmux list`)
   - The lock check correctly catches a locked device
   - A full backup completes with `SnapshotState: finished`

4. Update the README if your change affects usage or adds new behaviour.

5. Open a pull request against `master` with a clear description of what was changed and why.

## Code style

`iphone-backup.sh` is a Bash script. Please follow these conventions:

- Use `set -euo pipefail` (already set) — don't disable it.
- Prefer `[[ ]]` over `[ ]` for conditionals.
- Quote all variables: `"$VAR"` not `$VAR`.
- Use descriptive variable names in UPPER_CASE for globals.
- Add a comment for any non-obvious logic.

## Adding support for a new platform or iOS version

If you've tested on a Linux distro not listed in the README, or confirmed compatibility with a new iOS version, please open a PR or issue to update the compatibility notes.

## Dependency updates

`pymobiledevice3` is updated frequently to track iOS releases. If a new version fixes a bug or adds compatibility, open an issue or PR referencing the upstream changelog.

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).
