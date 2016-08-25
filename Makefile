THIS_DIRECTORY := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

# The build process has two steps:
# 1. build all holograms and packages and copy them into there
# 2. make a pacman repo in the repo/ subdirectory
all: build-holograms build-packages create-repo

create-repo: build-holograms build-packages
	@cd repo && perl ../prune_repo.pl
	@repo-add -n repo/holograms.db.tar.xz repo/*.pkg.tar.xz
	@rm -f repo/holograms.db.tar.xz.old
	@ln -sf holograms.db repo/holograms.files

pull-repo:
	@rsync -vau --delete-delay --progress bethselamin:/data/static-web/repo.holocm.org/archlinux/personal/ $(THIS_DIRECTORY)/repo/

push-repo: create-repo
	@rsync -vau --delete-delay --progress $(THIS_DIRECTORY)/repo/ bethselamin:/data/static-web/repo.holocm.org/archlinux/personal/

################################################################################
# compile holograms

HOLOBUILD_HOLOGRAMS = $(patsubst %.pkg.toml,%-pkg-toml,$(wildcard holo*.pkg.toml*))

build-holograms: $(HOLOBUILD_HOLOGRAMS)

%-pkg-toml: %.pkg.toml
	@cd repo && perl ../build_package_with_holo.pl ../$<

################################################################################
# compile AUR packages

# These are the packages that I want.
build-packages: package-ages-website
build-packages: package-broadcom-wl-dkms
build-packages: package-gandi-dyndns # this package is not hosted in the AUR
build-packages: package-gnaural package-gnaural-presets
build-packages: package-gogs
#build-packages: package-otf-titillium # disabled because this is not yet transferred to AUR4, it seems
build-packages: package-otf-titillium-selfpackaged
build-packages: package-pwget
build-packages: package-ripit
build-packages: package-screen-message
build-packages: package-todolist # self-built
build-packages: package-ttf-montserrat
build-packages: package-vimprobable2
build-packages: package-xmpp-bridge
build-packages: package-yaourt

# These are dependencies between these packages.
package-gogs: package-glide
package-gnaural-presets: package-gnaural
package-ripit: package-perl-mp3-tag
package-yaourt: package-package-query

# the build rule for all packages
package-%:
	@cd $* && perl ../build_package.pl $* $^
