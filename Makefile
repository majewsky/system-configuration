# The build process has two steps:
# 1. build all holograms and packages and copy them into there
# 2. make a pacman repo in the repo/ subdirectory
all: build-holograms build-packages

restart-repo:
	rm -f repo/holograms.{db,files}.tar.xz
	repo-add repo/holograms.db.tar.xz repo/*.pkg.tar.xz
	rm -f repo/holograms.{db,files}.tar.xz.old

pull-repo:
	@rsync -vau --delete-delay --progress bethselamin:/data/static-web/repo.holocm.org/archlinux/personal/ $(CURDIR)/repo/

push-repo: all
	@rsync -vau --delete-delay --progress $(CURDIR)/repo/ bethselamin:/data/static-web/repo.holocm.org/archlinux/personal/

################################################################################
# compile holograms

HOLOBUILD_HOLOGRAMS = $(patsubst %.pkg.toml,%-pkg-toml,$(wildcard holo*.pkg.toml*))

build-holograms:
	cd repo && perl ../build-holograms.pl ../*.pkg.toml

################################################################################
# compile AUR packages

# These are the packages that I want.
build-packages: $(patsubst %/PKGBUILD,package-%,$(wildcard */PKGBUILD))

# These are dependencies between these packages.
package-gogs: package-glide
package-ripit: package-perl-mp3-tag
package-yaourt: package-package-query

# the build rule for all packages
package-%: %/.SRCINFO
	cd $* && perl ../build_package.pl $* $^

%/.SRCINFO: %/PKGBUILD
	@cd $* && mksrcinfo
