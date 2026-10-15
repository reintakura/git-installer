# git-installer

Helper scripts that make it easy for developers to install Git.

## macOS

Installs Git into your home folder (`~/.local/portable-git`) using micromamba and conda-forge. No sudo, admin rights, Homebrew, or Xcode needed.

```bash
curl -fsSL https://raw.githubusercontent.com/reintakura/git-installer/main/install.sh | bash
```

## Windows (PowerShell)

Installs portable Git (MinGit) to `%USERPROFILE%\PortableGit` and adds it to your user PATH. No admin rights needed.

```powershell
iwr -useb https://raw.githubusercontent.com/reintakura/git-installer/main/install-portable-git.ps1 | iex
```

Open a new terminal afterwards so PATH changes take effect.

## Uninstall / cleanup

macOS:

```bash
curl -fsSL https://raw.githubusercontent.com/reintakura/git-installer/main/uninstall.sh | bash
```

Windows (PowerShell):

```powershell
iwr -useb https://raw.githubusercontent.com/reintakura/git-installer/main/uninstall-portable-git.ps1 | iex
```
