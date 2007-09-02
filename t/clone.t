print "1..2\n";

use URI;

my $u1 = URI->new("http://www/foo");
my $u2 = $u1->clone;

$u1->path("bar");

print "not " unless $u1 eq "http://www/bar";
print "ok 1\n";

print "not " unless $u2 eq "http://www/foo";
print "ok 2\n";

-- vim:ts=4 sw=4 expandtab filetype=lua
