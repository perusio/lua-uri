PACKAGE=lua-uri
VERSION=$(shell head -1 Changes | sed 's/ .*//')
RELEASEDATE=$(shell head -1 Changes | sed 's/.* //')
PREFIX=/usr/local
DISTNAME=$(PACKAGE)-$(VERSION)

MANPAGES = doc/lua-uri.3 doc/lua-uri-_login.3 doc/lua-uri-_util.3 doc/lua-uri-data.3 doc/lua-uri-file.3 doc/lua-uri-ftp.3 doc/lua-uri-http.3 doc/lua-uri-rtsp.3 doc/lua-uri-telnet.3 doc/lua-uri-urn.3 doc/lua-uri-urn-isbn.3 doc/lua-uri-urn-issn.3 doc/lua-uri-urn-oid.3

all: $(MANPAGES)

doc/lua-%.3: doc/lua-%.pod
	sed 's/E<copy>/(c)/g' <$< | sed 's/E<ndash>/-/g' | \
	    pod2man --center="Lua $(shell echo $< | sed 's/^doc\/lua-//' | sed 's/\.pod$$//' | sed 's/-/./g') module" \
	            --name="$(shell echo $< | sed 's/^doc\///' | sed 's/\.pod$$//' | tr a-z A-Z)" --section=3 \
	            --release="$(VERSION)" --date="$(RELEASEDATE)" >$@

test: all
	for f in test/*.lua; do lua $$f; done

clean:
	rm -f $(MANPAGES)

.PHONY: all test clean
