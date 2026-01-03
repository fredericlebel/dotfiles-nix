# dotfiles-nix

> curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
info: downloading installer
 INFO nix-installer v3.15.1
`nix-installer` needs to run as `root`, attempting to escalate now via `sudo`...
Password:
 INFO nix-installer v3.15.1
 INFO For a more robust Nix installation, use the Determinate package for macOS: https://dtr.mn/determinate-nix
Nix install plan (v3.15.1)
Planner: macos (with default settings)

Planned actions:
* Install Determinate Nixd
* Create an encrypted APFS volume `Nix Store` for Nix on `disk3` and add it to `/etc/fstab` mounting on `/nix`
* Extract the bundled Nix (originally from /nix/store/hwxncwfxh9sndswqgjbiv7ssjx57ikny-nix-binary-tarball-3.15.1/nix-3.15.1-aarch64-darwin.tar.xz) to `/nix/temp-install-dir`
* Create a directory tree in `/nix`
* Synchronize /nix/var ownership
* Move the downloaded Nix into `/nix`
* Synchronize /nix/store ownership
* Create build users (UID 351-382) and group (GID 350)
* Configure Time Machine exclusions
* Setup the default Nix profile
* Place the Nix configuration in `/etc/nix/nix.conf`
* Configure the shell profiles
* Configuring zsh to support using Nix in non-interactive shells
* Create a `launchctl` plist to put Nix into your PATH
* Configure the Determinate Nix daemon
* Remove directory `/nix/temp-install-dir`


Proceed? ([Y]es/[n]o/[e]xplain): y
 INFO Step: Install Determinate Nixd
 INFO Step: Create an encrypted APFS volume `Nix Store` for Nix on `disk3` and add it to `/etc/fstab` mounting on `/nix`
 INFO Step: Provision Nix
 INFO Step: Create build users (UID 351-382) and group (GID 350)
 INFO Step: Configure Time Machine exclusions
 INFO Step: Configure Nix
 INFO Step: Configuring zsh to support using Nix in non-interactive shells
 INFO Step: Create a `launchctl` plist to put Nix into your PATH
 INFO Step: Configure the Determinate Nix daemon
 INFO Step: Remove directory `/nix/temp-install-dir`
Nix was installed successfully!
To get started using Nix, open a new shell or run `. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh`
