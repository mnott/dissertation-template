use strict;
use warnings;

my $doctype = "";
if ($#ARGV + 1 > 0 ) {
    $doctype = $ARGV[0];
    shift;
}

#
# Load the Parser
#
my $parserfile = "templates/parser.cfg";
my $parser = [];
my $currentitem = "";
my $itemlevel = '0';
open my $info, $parserfile or die "Could not open $parserfile: $!";

while ( my $line = <$info> ) {
	$line =~ s/^#.*$//g;            # Lines starting as comments
	$line =~ s/\s+#.*$//g;          # In-line comments
	$line =~ s/'(.*)',\s*$/$1/g;    # Outer single quotes
	$line =~ s/\\'/'/g;             # Reading escaped single quotes
	$line =~ s/nomarkdown\(/nomarkdown(/g;
	$line =~ s/nospace\(/nospace(/g;
	if ( $line =~ m/^(.*)'\s*=>\s*'(.*)$/ ) {
		my %pline;
		$pline{"s"}  = "$1";
		$pline{"r"}  = "$2";
		$pline{"$1"} = "$2";
		push @{ $parser }, \%pline;
	}
}
close $info;

sub parse {
    my ( $input, $arg_ref ) = @_;

    my $output;

    for ( split /^/, $input ) {
        chomp;
        my $line = $_;

        my $content = $line;
        my $comment = "";

        #
        # Really dirty hack to parse comments: we have
        # to differentiate between actual comments, in
        # which case we want to not parse anything until
        # the end of the line, and some arbitrary percent
        # sign somewhere on the line, which, because of
        # how LaTeX works, would logically have been
        # escaped with a leading \. If we did have a
        # real comment, we parse only the part up to
        # the comment.
        #
        # Otherwise, we need to parse the whole line.
        # To do so, we first replace escaped comments
        # by some string that we hope does not exist
        # on the line, leaving any eventually true
        # comments alone.
        #
        # Then we split at those true comments, if any,
        # and parse only the first half.
        #
        $line =~ s/\\%/!NOCOMMENT!/g;

        if ( $line =~ m/(.*?)%(.*)$/ ) {
            $content = $1;
            $comment = "%" . $2;
        }

        for my $pline ( @{ $parser } ) {
            my $search  = %$pline{"s"};
            my $replace = %$pline{"r"};
            $replace =~ s/\\/\\\\/g;
            $content =~ s/$search/$replace/eeg;
        }

        $content =~ s/!NOCOMMENT!/\%/g;
        $comment =~ s/!NOCOMMENT!/\%/g;

        #
        # Automatically downgrade parts to sections etc.
        # when changing from book to article
        #
        if ( $doctype ne "book" ) {
            $content =~ s/^\\subsubsection/\\subparagraph/g;
            $content =~ s/^\\subsection/\\paragraph/g;
            $content =~ s/^\\section/\\subsubsection/g;
            $content =~ s/^\\chapter/\\subsection/g;
            $content =~ s/^\\part/\\section/g;
        }

        #
        # Test for itemizes
        #
        $content = itemize($content);

        #
        # Reconcatenate content and comments (if any)
        #
        $output .= "$content$comment\n";
    }
    return $output;
}

#
# nospace
#
# Simple function to remove Spaces from a String
#
# This function is called from some regular expressions
# that e.g. want to translate a "Section Header" into
# a label like "Section-Header".
#
# Inside a regular expression it is called, on the
# replace side, like so:
#
# '"...".nospace($1)."..."'
#
# It is important that you get the variable passed to it
# using shift, not relying on $_; otherwise you'll get
# the whole match string, not just the group you're
# looking for.
#
# TODO: Experiment how to put this not inside this module,
#       so that the user can overwrite this from the parser
#       configuration file
#
# $str   : The string to parse
# returns: The parsed string with spaces replaced by -
#
sub nospace {
    my ( $str, $arg_ref ) = @_;

    $str =~ s/ /-/g;

    return $str;
}


#
# Drop any Markdown (for auto generated header labels)
#
# TODO: Experiment how to put this not inside this module,
#       so that the user can overwrite this from the parser
#       configuration file
#
sub nomarkdown {
    my ( $str, $arg_ref ) = @_;

    $str =~ s/\[[^\]]*\]//g;

    return $str;
}


#
# itemize
#
# Working with itemizes
#
# TODO: For the moment we support only one
#       level, as Scrivener doesn't really
#       support more anyway (if we convert
#       rtf to txt, only one level is there
#       to be identified):
#
#       If we export from Scrivener, we can
#       have only two levels of itemizes:
#
#       Case a):
#
#       \t         => Level 1
#       &middot;\t => Level 2
#
#       Case b):
#
#       &middot;\t => Level 1
#       \t         => Level 2
#
#       Any further indentation from the point
#       of view of Scrivener will not be
#       reflected in the converted text file.
#       Hence, we have at best two levels of
#       indentation.
#
#       For simplification, let's name a line
#       starting with \t "t", one with "&middot;\t"
#       as "m", and otherwise "" - which will be
#       in $currentitem.
#
#       $itemlevel will be 0, 1 or 2.
#
#       So we have this cases for what we found
#       at the beginning of the line:
#
#        Case Found   $itemlevel  $currentitem Action
#       ---------------------------------------------
#         1   ""      1 or 2      m or t        E1
#         2   "\t"    0           ""            E2
#         3   "\t"    1 or 2      t             E3
#         4   "\t"    1           m             E4
#         5   "\t"    2           m             E5
#         6   "m"     0           ""            E2
#         7   "m"     1 or 2      m             E3
#         8   "m"     1           t             E4
#         9   "m"     2           t             E5
#
#
#       E1: * End all itemizes
#           - End as many itemizes as we had (1 or 2)
#             as per $itemlevel by adding \end{itemize}s
#           - $itemlevel=0;
#           - $currentitem="";
#
#       E2: * Start level 1
#           - Prefix line with \begin{itemize}\item
#           - $itemlevel=1;
#           - $currentitem = (what was found);
#
#       E3: * Continue on same level
#           - Prefix line with \item
#
#       E4: * Start level 2
#           - Prefix line with \begin{itemize}\item
#           - $itemlevel=2;
#           - $currentitem = (what was found);
#
#       E5: * End level 2
#           - Prefix line with \end{itemize\n\item
#           - $itemlevel=1;
#           - $currentitem = (what was found);
#
#       In all cases, we need to replace a given
#       "&middot;" by "\t" on level 1, or  "\t\t"
#       on level 2, as otherwise LaTeX will not
#       compile. Similarly, on level 2, we will
#       replace "\t" by "\t\t". Maintaining the
#       indentation level is cosmetic only at this
#       point.
#
#  Yes. I know. It is horrific. But it's working for now...
#
# $line  : The line to parse for detecting itemizes
# returns: The parsed line, with optionally added itemize etc.
#
sub itemize {
    my ( $line, $arg_ref ) = @_;

    if (   !( $line =~ /^[\t]+.*$/ )
        && !( $line =~ /^[\t]*\&middot;\t.*$/ )
        && $currentitem ne "" )
    {
        # 1 => E1
        if ( $itemlevel == 2 ) {
            $line = "\\end{itemize}\n\\end{itemize}\n\n" . $line;
        }
        elsif ( $itemlevel == 1 ) {
            $line = "\\end{itemize}\n\n" . $line;
        }
        $currentitem = "";
        $itemlevel = 0;
        return $line;
    }
    elsif ( $line =~ /^[\t]+(.*)$/ ) {
        my $content = $1;
        if ( $itemlevel == 0 && $currentitem eq "" ) {
            # 2 => E2
            $content = "\\begin{itemize}\n\t\\item $content";
            $itemlevel = 1;
            $currentitem = "t";
        }
        elsif ( $itemlevel > 0 && $currentitem eq "t" ) {
            # 3 => E3
            if ( $itemlevel == 1 ) {
                $content = "\t\\item $content";
            }
            else {
                $content = "\t\t\\item $content";
            }
        }
        elsif ( $itemlevel == 1 && $currentitem eq "m" ) {
            # 4 => E4
            $content = "\\begin{itemize}\n\t\t\\item $content";
            $itemlevel = 2;
            $currentitem = "t";
        }
        elsif ( $itemlevel == 2 && $currentitem eq "m" ) {
            # 5 => E5
            $content = "\\end{itemize}\n\t\\item $content";
            $itemlevel = 1;
            $currentitem = "t";
        }
        $line = $content;
    }
    elsif ( $line =~ /^[\t]*\&middot;\t(.*)$/ ) {
        my $content = $1;
        if ( $itemlevel == 0 && $currentitem eq "" ) {
            # 6 => E2
            $content = "\\begin{itemize}\n\t\\item $content";
            $itemlevel = 1;
            $currentitem = "m";
        }
        elsif ( $itemlevel > 0 && $currentitem eq "m" ) {
            # 7 => E3
            if ( $itemlevel == 1 ) {
                $content = "\t\\item $content";
            }
            else {
                $content = "\t\t\\item $content";
            }
        }
        elsif ( $itemlevel == 1 && $currentitem eq "t" ) {
            # 8 => E4
            $content = "\\begin{itemize}\n\t\t\\item $content";
            $itemlevel = 2;
            $currentitem = "m";
        }
        elsif ( $itemlevel == 2 && $currentitem eq "t" ) {
            # 9 => E5
            $content = "\\end{itemize}\n\t\\item $content";
            $itemlevel = 1;
            $currentitem = "m";
        }
        $line = $content;
    }

    return $line;
}

#
# Single Line Escapes
#
my $file = "";

while (<>) {
	#
	# Escape Obsidian Double Brackets
	#
#	s/\[\[(.*)\]\]/[$1]/g;

	#
	# Use our Parser
	#
	$_ = parse($_);

	#
	# Concatenate the result
	#
	$file .= $_;
}

#
# Multi Line Escapes
#

#
# Escape Plain LaTeX Environments
#
$file =~ s/```latex(.*?)```/$1/gms;

$file =~ s/```(.*?)```/$1/gms;

$file =~ s/`(.*?)`/$1/gms;

#
# Endnotes and Footnotes
#
$file =~ s/\s*__\(e\)(.*?)__/\\endnote{$1}/gms;
$file =~ s/\s*__(.*?)__/\\footnote{$1}/gms;

#
# Print Output
#
print $file;