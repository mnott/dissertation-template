#!/usr/bin/perl
#
# add_obsidian_links.pl - Add clean Obsidian links to content files
#
# For each .md file in Content directories:
#   - Adds YAML frontmatter with "up:" link to the parent folder note
#   - Skips files that already have YAML frontmatter
#   - Skips MOC files (FolderName.md where name matches parent dir)
#   - Skips - -.md files
#   - Skips template.md, include.md
#
# Usage: perl add_obsidian_links.pl <content_directory>
#

use strict;
use warnings;
use File::Find;
use File::Basename;
use File::Spec;
use Cwd 'abs_path';

my $root = $ARGV[0] or die "Usage: $0 <content_directory>\n";
$root = abs_path($root);

find(\&process_file, $root);

sub process_file {
    my $file = $File::Find::name;
    return unless -f $file && $file =~ /\.md$/;

    my $basename = basename($file, '.md');
    my $dir = dirname($file);
    my $dirname = basename($dir);

    # Skip special files
    return if $basename eq '- -';
    return if $basename eq 'template';
    return if $basename eq 'include';

    # Check if this is a MOC file (filename matches directory name)
    my $is_moc = ($basename eq $dirname);

    # Read current content
    open my $fh, '<', $file or return;
    my $content = do { local $/; <$fh> };
    close $fh;

    # Skip if already has YAML frontmatter
    return if $content =~ /\A---\s*\n/;

    if ($is_moc) {
        # MOC files: add up link to parent directory's MOC
        my $parent_dir = dirname($dir);
        my $parent_name = basename($parent_dir);

        # Don't link to the root content dir
        return if $parent_name eq 'Research Proposal' && $basename ne 'Research Proposal';

        my $frontmatter = "---\nup: \"[[$parent_name]]\"\n---\n\n";

        open my $out, '>', $file or return;
        print $out $frontmatter . $content;
        close $out;

        print "MOC: $basename -> up: $parent_name\n";
    } else {
        # Content files: link up to the folder note (same dir name)
        my $frontmatter = "---\nup: \"[[$dirname]]\"\n---\n\n";

        open my $out, '>', $file or return;
        print $out $frontmatter . $content;
        close $out;

        print "Content: $basename -> up: $dirname\n";
    }
}
