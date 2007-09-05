all:

test:
	for f in t/{_util,clone,escape,file,ftp,generic,http,mailto,mms,news,pop,query,rel,rfc2732,roy-test,rsync,rtsp,sip,urn-oid}.t; do lua $$f; done

.PHONY: all test
