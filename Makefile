THIS_DIRECTORY := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

# The build process has two steps:
# 1. build all holograms and packages and copy them into there
# 2. make a pacman repo in the repo/ subdirectory
all: build-holograms build-packages create-repo

create-repo: build-packages
	@rm -f -- repo/holo.db*
	@repo-add repo/holo.db.tar.gz repo/*.pkg.tar.xz

################################################################################
# compile holograms

MAKEPKG_HOLOGRAMS   = $(dir $(wildcard holo*/PKGBUILD))
HOLOBUILD_HOLOGRAMS = $(patsubst %.toml,%-toml,$(wildcard holo*.toml))
.PHONY: $(MAKEPKG_HOLOGRAMS)

build-holograms: $(MAKEPKG_HOLOGRAMS) $(HOLOBUILD_HOLOGRAMS)
	@echo $^

%-toml: %.toml
	@cd repo && perl ../build_package_with_holo.pl ../$<

$(MAKEPKG_HOLOGRAMS): .env
	@cd $@ && perl ../build_package.pl $(patsubst %/,%,$@)

################################################################################
# compile AUR packages

# These are the packages that I want.
build-packages: package-broadcom-wl-dkms
#build-packages: package-cargo-bin                         # disabled because build_package.pl gets confused by the calculated pkgver()
build-packages: package-cutegram
build-packages: package-gnaural package-gnaural-presets
#build-packages: package-otf-titillium                     # disabled because this is not yet transferred to AUR4, it seems
build-packages: package-otf-titillium-selfpackaged
build-packages: package-ripit
build-packages: package-screen-message
build-packages: package-vimprobable2
build-packages: package-yaourt

# These are dependencies between these packages.
package-cutegram: package-telegramqml package-libqtelegram-ae
package-telegramqml: package-libqtelegram-ae
#package-gnaural-presets: package-gnaural
package-ripit: package-perl-mp3-tag
package-yaourt: package-package-query

# the build rule for all packages
package-%:
	@cd $* && perl ../build_package.pl $* $^
