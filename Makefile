all:

test:
	for f in t/{_util,clone,escape,file,ftp,generic,http,mms,news,pop,query,rel,rfc2732,rsync,rtsp,sip,urn-oid}.t; do lua $$f; done

.PHONY: all test
