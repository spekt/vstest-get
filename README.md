# VSTest installer

![Maintenance](https://img.shields.io/maintenance/no/2018)

Set of scripts to install portable `vstest.console` runner on your desktop. The
portable test runner only requires .NET runtime (no external dependencies like VS).

We also ship a docker image cooked with these scripts, check out [vstest-docker](https://github.com/spekt/vstest-docker)!

## Usage | Windows
```powershell
# Powershell
# Installs to ~/.vstest by default
> iex (new-object net.webclient).downloadstring("https://raw.githubusercontent.com/spekt/vstest-get/master/install.ps1")

# Install to any directory
# Download install.ps1 from https://raw.githubusercontent.com/spekt/vstest-get/master/install.ps1
> .\install.ps1 c:\tmp\vstest

# List available versions
> .\install.ps1 -l
```

## Usage | *nix
```bash
# Bash
# Installs to ~/.vstest by default
> (curl -s https://raw.githubusercontent.com/spekt/vstest-get/master/install.sh) | bash /dev/stdin

# Installs to /tmp/vstest
> (curl -s https://raw.githubusercontent.com/spekt/vstest-get/master/install.sh) | bash /dev/stdin /tmp/vstest

# List available versions
> (curl -s https://raw.githubusercontent.com/spekt/vstest-get/master/install.sh) | bash /dev/stdin -l
```

## License
MIT

## Contribute
Any contribution (issues, pull requests, forks, stars and cookies) are most welcome!
