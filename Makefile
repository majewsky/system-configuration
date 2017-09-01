all: build push-repo

build:
	@# package/repo building by https://github.com/majewsky/art
	@art

pull-repo:
	@rsync -vau --delete-delay --progress bethselamin:/data/static-web/repo.holocm.org/archlinux/personal/ $(CURDIR)/repo/

push-repo: build
	@rsync -vau --delete-delay --progress $(CURDIR)/repo/ bethselamin:/data/static-web/repo.holocm.org/archlinux/personal/
