#!/usr/bin/perl
#
# strip_obsidian.pl - Strip Obsidian metadata from template/include files
#
# Removes:
#   - YAML frontmatter ONLY if it contains Obsidian keys (links:, related:, up:)
#   - *Links:* navigation lines
#   - Backtick fences (```)
#
# Usage: perl strip_obsidian.pl <file>
#

use strict;
use warnings;

# First pass: read the file and check if the frontmatter is Obsidian metadata
my @lines = <>;

my $has_obsidian_frontmatter = 0;
my $in_fm = 0;
my $fm_end = 0;

for (my $i = 0; $i < scalar @lines; $i++) {
    if ($lines[$i] =~ /^---\s*$/) {
        if (!$in_fm) {
            $in_fm = 1;
            next;
        } else {
            $fm_end = $i;
            last;
        }
    }
    if ($in_fm && $lines[$i] =~ /^(links|related|up)\s*:/) {
        $has_obsidian_frontmatter = 1;
    }
}

# Second pass: output with stripping
$in_fm = 0;
my $fm_done = 0;

for my $line (@lines) {
    # Strip Obsidian YAML frontmatter only
    if ($has_obsidian_frontmatter && !$fm_done) {
        if ($line =~ /^---\s*$/) {
            $in_fm = !$in_fm;
            $fm_done = 1 if !$in_fm;
            next;
        }
        next if $in_fm;
    }

    # Strip Obsidian Links footer
    next if $line =~ /^\*Links:\*/;

    # Strip backtick fences
    next if $line =~ /^```/;

    print $line;
}
