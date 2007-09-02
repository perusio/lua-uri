package URI::urn::oid;  # RFC 2061

@ISA=qw(URI::urn);

sub oid {
    my $self = shift;
    my $old = $self->nss;
    if (@_) {
        $self->nss(join(".", @_));
    }
    return split(/\./, $old) if wantarray;
    return $old;
}

-- vi:ts=4 sw=4 expandtab
