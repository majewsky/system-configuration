# How to update

```bash
cd system-configuration/ages-website # this directory
git -C /path/to/ages-website archive --prefix=ages-website/ HEAD > ages-website.tar
$EDITOR PKGBUILD                     # bump version
mksrcinfo
make -C ..
```
