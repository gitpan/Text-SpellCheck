# vi:fdm=marker fdl=0 syntax=perl:
# $Id: main.t,v 1.11 2004/04/13 11:28:22 jettero Exp $

use Test;

plan tests => 3;
# plan tests => 14;

use Text::SpellCheck; ok 1;

my $s = new Text::SpellCheck; ok $s;

my $text = $s->html_highlight(
    "BEFORE",
    "AFTER",
    "this is a funnny <a href='neato'>message</a> man",
);

ok( $text eq "this is a BEFOREfunnnyAFTER <a href='neato'>message</a> man" );

# Really, I want all 14 tests...
# However, I discovered by testing on several machines, that 
# it isn't realistic to come up with a big suite of natural language tests...
# Different dictionaries produce a different number of mispellings!

__END__

# text2 {{{
# IRL I'm a terrible speller.  This is from a private forum of mine.  You won't find it on the web.
# But the post had a couple spelling errors in it and they highlighted some unexpected bugs.
# *POOF*: a test.
my $text2 = $s->html_highlight(\&oker, q(
So, here's the deal.  Coffee that's too weak is not coffee at all.  It's hot water with coffee flavoring in it.  It doesn't have the
desired stimulant effects and it tastes like dirty water.  It's gross.  Someone replaced the coffee scoop for the coffee machine
upstairs (here at work) resulting in a cronic under coffinated brown water supplies.

It's been a serious problem for more than two weeks and I finally cannot take it anymore.  I have started a resistance movement.
For those of us that cannot drink this butt water, if we see through the batch; we then make a new pot (pouring out iff required) of
[i]actual[/i] coffee.  So far there's five of us in the resistance.  That is a lot for this small office.

So far it's been working out.  I think I've also cracked the case.  As mentioned, we have a new scoop.  Everyone [i]knows[/i] it's
smaller, so they have been using "EXTRA heaping scoops."  Well, that's not enough.  It now takes four scoops, and I have been
spreading the word.  It shouldn't be long now.  There may yet be real coffee again -- without my having to make a new batch for
every new cup I fetch.

This, therefore, is a wonderful development.  Ta.

ve ful vel ta), # this last little bit is tricksey ... for these mispellings occur IN spelled-right words!
);
# }}}
# text3 {{{
# http://www.voltar.org/kgcf/cgi/topic_show.pl?pid=130
# This particular post turned up the "spellchecking a number freezes SpellCheck.pm 4evar" bug.
# *POOF*: a test.
my $text3 = $s->html_highlight(\&oker, q(
I will be there for sure.<br>
<br>
On Thu, Apr 08, 2004 at 11:01:32AM -0400, David J. Hast wrote:<br>
> There will be an AGA Handicap Go Tournament in Grand Rapids, Michigan on<br>
> SATURDAY, MAY 8.  We expect this long-awaited tournament to be the first of<br>
> many to come.<br>
> <br>
> Grand Rapids is 2 hours from Ann Arbor, 3 hours from Chicago, 45 minutes<br>
> from Kalamazoo, and 2-3 hours from Northwest Indiana.  We hope to draw<br>
> players from all of these regions and have a big turnout.  There will be<br>
> prizes at different rank levels.<br>
> <br>
> More information, including fees, directions, etc., will follow.  This will<br>
> be an all day event, approx. 9am-5pm.<br>
> <br>
> Please pass on this information to your club members and other go players. at ./sc.pl line 18.
));
# }}}

sub oker {
    my $word = shift;
    my $alts = shift;

    ok(1);
}
