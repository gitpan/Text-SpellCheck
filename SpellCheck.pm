# vi:fdm=marker fdl=0:
# $Id: SpellCheck.pm,v 1.22 2004/04/13 11:28:31 jettero Exp $

package Text::SpellCheck;

use strict;
use warnings;

our $VERSION = '0.56';
use Carp;
use IPC::Open2;

1;

# new {{{
sub new { 
    my $this = shift;
    my $ispl = shift;

    $this = bless { aspell=>"/usr/bin/aspell" }, $this;
    $this->{aspell} = $ispl if defined $ispl and -f $ispl;

    croak "aspell not found ($this->{aspell})" unless -f $this->{aspell};

    return $this;
}
# }}}
# check_text {{{
sub check_text {
    my $this = shift;
    my @text = @_;
    my $words = {};

    local $SIG{PIPE} = sub { warn "FATAL ERROR: $this->{aspell} exited unexpectedly!\n"; exit 1 };

    my $pid = open2(*Reader, *Writer, "$this->{aspell} -a");
    my $ver = <Reader>;

    foreach my $string (@text) {
        while($string =~ m/([\'\w\d]+)(?![^<]*[>])/msg) {
            my $word = $1;

            unless( $words->{$word} or $word =~ m/^\d+$/ ) {
                print Writer "$word\n";

                # Aspell unexpectedly only returns one line if the word is only digits.
                # Hence the other condition in the unless() 

                # print STDERR "sending: $word\n";

                my $a = <Reader>; defined($a) or die "problem reading from aspell pipe: $!";
                my $b = <Reader>; defined($b) or die "problem reading from aspell pipe: $!";

                # print STDERR "\$a: $a\n";
                # print STDERR "\$b: $b\n";

              # $a: & damnn 41 0: damn, Damon, Damian, Damien, Damion, daemon, damns, demon, Mann, Dan, Danna, Danny, Deann, Diann,
              # adman, admen, admin, dam, damning, domain, Damn'd, Dana, Dane, Dawn, Donn, Dunn, dame, damming, damned, dampen,
              # damson, darn, dawn, Deming, amen, damp, dams, demean, doming, domino, taming

                $words->{$word} = [];

                if( $a =~ m/^\&.+?\s+(\d+)\s+(\d+):\s+(.+)/ ) {
                    my ($matches, $dunno, $options) = ($1, $2, $3);

                    $words->{$word} = [ split /\s*,\s*/, $options ];
                }
            }
        }
    }
    close Writer;
    close Reader;
    waitpid $pid, 0;

    return $words;
}
# }}}
# html_highlight {{{
sub html_highlight {
    my $this  = shift;
    my $st_hi = shift;
    my $en_hi = shift;
    my @text  = @_;

    my $format;
    if( ref($st_hi) eq "CODE" ) {
        $format = $st_hi;
        unshift @text, $en_hi;
    } else {
        $format = sub { return $st_hi . $_[0] . $en_hi };
    }

    my $words = $this->check_text( @text );

    foreach my $t (@text) {
        foreach my $w (keys %$words) {
            if( @{ $words->{$w} } > 0 ) {
                # this lookahead really helps to keep from matching inside the hotmetal tags...
                # a lookbehind may be needed, note that ?! won't do a look _behind_...
                $t =~ s/(?<![\w\'])$w(?![\w\'])(?![^<]*[>])/$format->($w, $words->{$w})/mseg;
            }
        }
    }

    return (wantarray ? @text : "@text");
}
# }}}

__END__

=head1 NAME

Text::SpellCheck - Uses the aspell binary to generate spellcheck info

=head1 SYNOPSIS

  use strict;
  use Text::SpellCheck;

  # I needed something that worked, that helped me implement the spellchecker for one of my websites, 
  # and that didn't need a C compiler.  This is it.  In general, I'd say it's crap.  It does work,
  # but the open2() -- aka open(FILE, "| aspell -a |") call is untested and probably fragile.

  # Nevertheless, to use it:

  my $sc = new Text::SpellCheck("/usr/bin/aspell");

  my $result_hash = $sc->check_text(qq(
      I have mispeled some of thesee words for you.
      Can you guess wich ones?
      There are some <html_protections trvial=1> little regexps for
      html</html_protections> but I wouldn't depend on them too much.
  ));

  foreach my $word (keys %$result_hash) {
      print "$word was dumb: @{ $result_hash->{$word} }\n";
  }

  This is handy:

  my $my_hightlit_text = $sc->html_highlight(
      q(<span style="background-color: yellow; color: red">),
      q(</span>),
      $some_curiously_spelled_text
  );

  And so is this:

  use CGI; my $cgi = new CGI;

  my $my_hi = $sc->html_highlight( \&my_lighter, $text );

  sub my_lighter {
      my $word  = shift; # the word as it was written
      my $words = shift; # alternatives (arrayref)

      return $cgi->popup_menu({default=>"*$word*", values=>["*$word*", @$words]});
  }

=head1 AUTHOR

Jettero Heller jettero@cpan.org

http://www.voltar.org

=head1 SEE ALSO

perl(1)

=cut
