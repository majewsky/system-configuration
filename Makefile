SUBDIRS = $(wildcard holo*-*)
.PHONY: $(SUBDIRS)
all: $(SUBDIRS)

$(SUBDIRS):
	@echo "Building $@..."
	$(MAKE) -C $@ $(MFLAGS)
