# system-configuration

This repo contains configuration for my private systems, formatted as Arch
Linux packages using my minimal configuration management tool
[Holo](https://github.com/majewsky/holo).

## License information

All the stuff that I wrote myself is licensed under AGPLv3, cf. the
[LICENSE](LICENSE) file. The following files are from other sources:

* `holodeck-damogran/gandi_dyndns.py` is a script maintained at
[lembregtse/gandi-dyndns](https://github.com/lembregtse/gandi-dyndns), which unfortunately
[lacks a proper license](https://github.com/lembregtse/gandi-dyndns/issues/9) at the time of this writing.

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
  a [https://stribika.github.io/2015/01/04/secure-secure-shell.html](hardened OpenSSH server).
