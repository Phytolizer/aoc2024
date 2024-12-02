sub absdiff(($a, $b)) { abs($a - $b) }

my @input = $*IN.lines.map: { $_.split(/\s+/).map(*.Int) };
my @lists = [Z] @input;
my @pairs = [Z] @lists.map(*.sort);
my $part1 = [+] @pairs.map(&absdiff);
my $weights = @lists[1].Bag;
my $part2 = [+] @lists[0].map: { $_ * $weights{$_} }
say "Part 1: $part1";
say "Part 2: $part2";
