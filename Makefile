THIS_DIRECTORY := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

# The build process has three steps:
# 1. clean the repo/ subdirectory
# 2. build all holograms and packages and copy them into there
# 3. make a pacman repo in the repo/ subdirectory
all: clean-repo build-holograms build-packages create-repo

clean-repo:
	@rm -f -- repo/holo.db* repo/*.pkg.tar.xz

create-repo: build-packages
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
build-packages: package-yaourt

# These are dependencies between these packages.
package-yaourt: package-package-query

# the build rule for all packages
package-%: clean-repo
	@cd $* && perl ../build_package.pl $* $^
