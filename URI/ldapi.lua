package URI::ldapi;

@ISA=qw(URI::_ldap URI::_generic);

require URI::Escape;

sub un_path {
    my $self = shift;
    my $old = URI::Escape::uri_unescape($self->authority);
    if (@_) {
        my $p = shift;
        $p =~ s/:/%3A/g;
        $p =~ s/\@/%40/g;
        $self->authority($p);
    }
    return $old;
}

sub _nonldap_canonical {
    my $self = shift;
    $self->URI::_generic::canonical(@_);
}

-- vi:ts=4 sw=4 expandtab
