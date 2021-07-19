# system-configuration

This repo contains configuration for my private systems, formatted as Arch
Linux packages using my minimal configuration management tool
[Holo](https://github.com/holocm/holo).

## License information

All the stuff that I wrote myself is licensed under AGPLv3, cf. the
[LICENSE](LICENSE) file. If parts of a package or all of a package is licensed
differently, the README for the individual package (found in the package's
subdirectory) will usually say so.

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
[Holo](https://github.com/holocm/holo) itself. It is identical to the version
found in the AUR, but development happens here first usually.

Hologram packages are built with [holo-build](https://github.com/holocm/holo-build).

The package repository is built with [art](https://github.com/majewsky/art).
