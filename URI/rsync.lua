package URI::rsync;  # http://rsync.samba.org/

# rsync://[USER@]HOST[:PORT]/SRC

@ISA=qw(URI::_server URI::_userpass);

sub default_port { 873 }

-- vi:ts=4 sw=4 expandtab
