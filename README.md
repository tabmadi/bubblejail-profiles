# Bubblejail Profiles

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)

A community collection of [Bubblejail](https://github.com/igo95862/bubblejail) sandbox
profiles for applications that don't ship a profile upstream, or where the upstream
profile needs tweaking.

[Bubblejail](https://github.com/igo95862/bubblejail) is a sandboxing utility for Linux
built on top of `bwrap` (Bubblewrap), used to confine desktop applications and limit
their access to your system.

## Project Structure

```
.
├── profiles/
│   ├── firefox.toml
│   ├── signal.toml
│   └── ...
└── scripts/
    ├── install.sh
    └── remove-instance.sh
```

Each profile is a single `<application>.toml` file placed directly in `profiles/`. See the
[Bubblejail profile documentation](https://github.com/igo95862/bubblejail/blob/master/doc/services.md)
and the [profiles shipped with Bubblejail](https://github.com/igo95862/bubblejail/tree/master/src/bubblejail/profiles)
for the file format and available services.

## Installation

### Prerequisites

- [Bubblejail](https://github.com/igo95862/bubblejail) installed and configured.

### Install profiles

Clone the repository and run the install script:

```bash
git clone https://github.com/<your-org>/bubblejail-profiles.git
cd bubblejail-profiles

# Install all profiles (symlinked into ~/.local/share/bubblejail/profiles)
./scripts/install.sh

# Install only specific profiles
./scripts/install.sh firefox signal

# Copy instead of symlink
./scripts/install.sh --copy

# List all available profiles
./scripts/install.sh --list
```

If you have [Mise](https://mise.jdx.dev/) installed, you can run the same script via the
`install` task instead:

```bash
mise run install
mise run install -- firefox signal
mise run install -- --copy
```

By default profiles are symlinked into `$XDG_DATA_HOME/bubblejail/profiles`
(usually `~/.local/share/bubblejail/profiles`), so the repository can be `git pull`-ed
to receive updates. Use `--copy` if you'd rather have an independent copy you can edit
locally.

Once installed, a profile becomes available when creating a new instance:

```bash
bubblejail create --profile <name> <instance-name>
```

## Adding a Profile

1. Create a `<application>.toml` file in `profiles/`.
2. Use the existing profiles and the
   [Bubblejail documentation](https://github.com/igo95862/bubblejail/blob/master/doc/services.md)
   as a reference for available services and options.
3. Test the profile locally with `./scripts/install.sh --copy <application>`
   followed by `bubblejail create --profile <application> test-instance`.
4. Once you're done testing, remove the instance with
   `./scripts/remove-instance.sh test-instance`. This deletes the instance's
   data directory, its desktop entry, and its runtime lock/socket directory.
5. Open a pull request following [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/).

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the project
2. Create your feature branch (`git checkout -b feature/some-app-profile`)
3. Commit your changes using [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
4. Push to the branch (`git push origin feature/some-app-profile`)
5. Open a Pull Request

## Security

Please see [SECURITY.md](SECURITY.md) for our security policy.

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.
