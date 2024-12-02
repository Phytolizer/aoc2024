sub uncurry(&f) { -> ($a, $b) {f($a, $b)} }
my &absdiff = &abs o uncurry(&infix:<->);

my @input = $*IN.lines.map(*.split(/\s+/).map(*.Int));
my @lists = [Z] @input;
my @pairs = [Z] @lists.map(*.sort);
my $part1 = [+] @pairs.map(&absdiff);
my $weights = @lists[1].Bag;
my $part2 = [+] @pairs.map: -> ($a, $b) {
    $a * $weights{$a}
}
say "Part 1: $part1";
say "Part 2: $part2";
