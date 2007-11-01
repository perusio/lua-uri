PACKAGE=lua-uri
VERSION=$(shell head -1 Changes | sed 's/ .*//')
RELEASEDATE=$(shell head -1 Changes | sed 's/.* //')
PREFIX=/usr/local
DISTNAME=$(PACKAGE)-$(VERSION)

MANPAGES = doc/lua-uri.3

all: $(MANPAGES)

doc/lua-uri.3: doc/lua-uri.pod
	sed 's/E<copy>/(c)/g' <$< | sed 's/E<ndash>/-/g' | \
	    pod2man --center="Lua URI module" \
	            --name="LUA-URI" --section=3 \
	            --release="$(VERSION)" --date="$(RELEASEDATE)" >$@

test: all
	for f in test/*.lua; do lua $$f; done

clean:
	rm -f $(MANPAGES)

.PHONY: all test clean
