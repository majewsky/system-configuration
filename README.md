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

## Shared pieces

* [hologram-base](hologram-base) contains everything that is shared across all
  my systems (tools, daemons, etc.). It also includes...

* [hologram-openssh](hologram-openssh) is a subhologram of base that configures
  a [hardened OpenSSH server](https://stribika.github.io/2015/01/04/secure-secure-shell.html).

* [hologram-user-dbus](hologram-user-dbus) enables the DBus session bus in
  systemd user sessions.

* [hologram-multimedia-base](hologram-multimedia-base) contains a selection of
  multimedia packages for the CLI.

## Holograms for Damogran

Damogran is my home server. Its [holodeck](holodeck-damogran) contains, among
other things, the following holograms:

* [hologram-damogran-audio](hologram-damogran-audio) contains the audio
  setup for Damogran (intranet-widely accessible PulseAudio and MPD).

* [hologram-damogran-dyndns](hologram-damogran-dyndns) contains the DynDNS
  setup for Damogran.

# How to build

Every subfolder (i.e. each hologram and holodeck) has a simple Makefile so
that `make` builds the package. The top-level directory has a Makefile with the
following targets:

    make all                # default: build all packages
    make hologram-base      # build just that package, identical to `make -C hologram-base`

Some holograms include sensible information that has been left out of this
public repo. This information is in my private clones of this repo only, in the
top-level directory of the repo in a `.env` file. The
[`env.example`](env.example) file shows which environment variables are
expected to be defined by `.env`.
