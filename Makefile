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

SUBDIRS = $(wildcard holo*)
.PHONY: $(SUBDIRS)
build-holograms: $(SUBDIRS)

$(SUBDIRS):
	@cd $@ && perl ../build_package.pl $@

################################################################################
# compile AUR packages

# These are the packages that I want.
build-packages: package-cutegram
build-packages: package-ripit
build-packages: package-screen-message
build-packages: package-vimprobable2
build-packages: package-yaourt

# These are dependencies between these packages.
package-cutegram: package-telegramqml package-libqtelegram-ae
package-telegramqml: package-libqtelegram-ae
package-ripit: package-perl-mp3-tag
package-yaourt: package-package-query

# the build rule for all packages
package-%:
	@cd $* && perl ../build_package.pl $* $^
