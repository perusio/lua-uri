package URI::ssh;
@ISA=qw(URI::_login);

# ssh://[USER@]HOST[:PORT]/SRC

sub default_port { 22 }

-- vi:ts=4 sw=4 expandtab
