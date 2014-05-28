EXECUTABLE=$(BINDIR)/redirecthang
DEPS= snapframework/snap-core snapframework/snap-server \
	snapframework/snap-loader-static snapframework/snap \
	mattraibert/snap-loader-dynamic
INSTALLFLAGS=-j -fdevelopment

EXEC=cabal exec --
RUN=$(EXEC) runghc -isrc
BINDIR=.cabal-sandbox/bin
BUILDDIR=dist
SOURCES=$(shell find src -type f -iname '*.hs')
DEPDIR=deps
SHELL=/bin/bash

.PHONY: all install clean superclean init deps sandbox tags confirm


all: init install tags

install: $(EXECUTABLE)

$(EXECUTABLE): $(SOURCES)
	cabal install $(INSTALLFLAGS)

run: $(EXECUTABLE)
	$(EXECUTABLE)

clean:
	rm -rf $(BUILDDIR) $(EXECUTABLE)

superclean: confirm clean
	rm -rf $(DEPDIR) .cabal-sandbox/ cabal.sandbox.config TAGS

confirm:
	@read -r -p "Are you sure? [y/N] " CONTINUE; \
	[[ ! $$CONTINUE =~ ^[Yy]$$ ]] && exit 1; echo "Continuing...";

init: sandbox deps

deps: $(patsubst %, $(DEPDIR)/%.d, $(DEPS))

$(DEPDIR)/%.d:
	git clone git@github.com:$*.git $@
	cabal sandbox add-source $@


sandbox: cabal.sandbox.config

cabal.sandbox.config:
	cabal sandbox init


tags: TAGS

TAGS: $(SOURCES)
	$(EXEC) haskdogs -e
