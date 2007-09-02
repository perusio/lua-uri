package URI::http;

@ISA=qw(URI::_server);

sub default_port { 80 }

sub canonical
{
    my $self = shift;
    my $other = $self->SUPER::canonical;

    my $slash_path = defined($other->authority) &&
        !length($other->path) && !defined($other->query);

    if ($slash_path) {
        $other = $other->clone if $other == $self;
        $other->path("/");
    }
    $other;
}

-- vi:ts=4 sw=4 expandtab
