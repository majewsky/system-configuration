THIS_DIRECTORY := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

SUBDIRS = $(wildcard holo*)
.PHONY: all repo $(SUBDIRS)
all: $(SUBDIRS)

$(SUBDIRS):
	@echo "Building $@..."
	$(MAKE) -C $@ $(MFLAGS)

repo:
	@mkdir -p repo
	@rm -f -- repo/holo.db* repo/*.pkg.tar.xz
	env PKGDEST="$(THIS_DIRECTORY)/repo" $(MAKE) all
	repo-add repo/holo.db.tar.gz repo/*.pkg.tar.xz
