# system-configuration

This repo contains configuration for my private systems, formatted as Arch
Linux packages using my minimal configuration management tool
[Holo](https://github.com/majewsky/holo).

## License information

All the stuff that I wrote myself is licensed under AGPLv3, cf. the
[LICENSE](LICENSE) file. If parts of a package or all of a package is licensed
differently, the README for the individual package (found in the package's
subdirectory) will say so.

# Contents

My naming convention draws on Holo's name and includes:

* **holograms**: General configuration packages for a certain aspect of a
  system (e.g. a certain service or a certain set of tools).
* **holodecks**: Specific configuration packages for a single system, such that
  the whole system can be re-created by installing just that package. (Of
  course, filesystems etc. still need to be set up manually; a package manager
  cannot and should not do that.)

## Tools

The [holo](holo) subdirectory contains the PKGBUILD for
[Holo](https://github.com/majewsky/holo) itself. It is identical to the version
found in the AUR, but development happens here first usually.

## Shared pieces

* [hologram-base](hologram-base) contains everything that is shared across all
  my systems (tools, daemons, etc.). It also includes...

* [hologram-openssh](hologram-openssh) is a subhologram of base that configures
  a [hardened OpenSSH server](https://stribika.github.io/2015/01/04/secure-secure-shell.html).

* [hologram-multimedia-base](hologram-multimedia-base) contains a selection of
  multimedia packages for the CLI.

* [hologram-dev-tools](hologram-dev-tools) contains a selection of compilers
  and development tools.

# Shared pieces for machines with GUI only

* [hologram-base-gui](hologram-base-gui) is a base hologram for systems with
  GUI, including [hologram-base](hologram-base),
  [hologram-multimedia-base](hologram-multimedia-base) and my basic GUI apps.

* [hologram-kde-desktop](hologram-kde-desktop) expands
  [hologram-base-gui](hologram-base-gui) with a Plasma desktop and KDE apps.

* [hologram-dtp](hologram-dtp) contains a package selection for my desktop
  publishing needs.

* [hologram-games](hologram-games) contains a selection of games.

## Holograms for Damogran

Damogran is my home server. Its [holodeck](holodeck-damogran) contains, among
other things, the following holograms:

* [hologram-user-dbus](hologram-user-dbus) enables the DBus session bus in
  systemd user sessions.

* [hologram-damogran-audio](hologram-damogran-audio) contains the audio
  setup for Damogran (intranet-widely accessible PulseAudio and MPD).

* [hologram-damogran-dyndns](hologram-damogran-dyndns) contains the DynDNS
  setup for Damogran.

## Holograms for Arcturus

Arcturus is my desktop PC. Its [holodeck](holodeck-arcturus) has no special
holograms and mostly configures the boot sequence and networking.

# How to build

Every subfolder (i.e. each hologram and holodeck) has a simple Makefile so that
`make` builds the package. The top-level directory has a Makefile with targets
for all the subdirectories, and a default target that builds all of them and
collects the resulting packages in a pacman repo in the `repo` subdirectory:

    make all                # default: build all packages and compile a pacman repo
    make hologram-base      # build just that package, identical to `make -C hologram-base`

Some holograms include sensible information that has been left out of this
public repo. This information is in my private clones of this repo only, in the
top-level directory of the repo in a `.env` file. The
[`env.example`](env.example) file shows which environment variables are
expected to be defined by `.env`.

## AUR

Some holograms reference packages from the AUR. These packages are included in
here as submodules (thanks to AUR4 being based on Git repositories), and can
individually be built with make targets of the form:

    make package-yaourt     # build the package yaourt and all of its dependencies

THe default target includes these package targets, so after `make all`, all
holodecks, holograms and included AUR packages will be present in the `repo`
subdirectory.
