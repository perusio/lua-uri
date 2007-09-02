print "1..3\n";

# Test mixing of URI and URI::WithBase objects
use URI;
use URI::WithBase;

my $str = "http://www.sn.no/";
my $rel = "path/img.gif";

my $u  = URI->new($str);
my $uw = URI::WithBase->new($str, "http:");

my $a = URI->new($rel, $u);
my $b = URI->new($rel, $uw);
my $d = URI->new($rel, $str);

print "not " unless $a->isa("URI") &&
                    ref($b) eq ref($uw) &&
                    $d->isa("URI");
print "ok 1\n";

-- vim:ts=4 sw=4 expandtab filetype=lua
