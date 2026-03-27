#!/usr/bin/perl
#
# rebuild_mocs.pl - Rebuild MOC files with clean Obsidian links
#
# For each directory in the content tree, creates/updates a FolderName.md
# MOC file with:
#   - YAML frontmatter with up: link to parent
#   - List of child files/dirs as wiki-links
#
# Usage: perl rebuild_mocs.pl <content_directory>
#

use strict;
use warnings;
use File::Basename;
use File::Spec;
use Cwd 'abs_path';

my $root = $ARGV[0] or die "Usage: $0 <content_directory>\n";
$root = abs_path($root);

process_dir($root, undef);

sub process_dir {
    my ($dir, $parent_name) = @_;
    my $dirname = basename($dir);
    my $moc_file = File::Spec->catfile($dir, "$dirname.md");

    # Collect children: subdirs and content files
    opendir my $dh, $dir or return;
    my @entries = sort grep { !/^\./ } readdir $dh;
    closedir $dh;

    my @child_dirs;
    my @child_files;

    for my $entry (@entries) {
        my $path = File::Spec->catfile($dir, $entry);
        if (-d $path) {
            push @child_dirs, basename($path);
        } elsif ($entry =~ /\.md$/) {
            my $name = basename($entry, '.md');
            # Skip the MOC itself, - -.md, template, include
            next if $name eq $dirname;
            next if $name eq '- -';
            next if $name eq 'template';
            next if $name eq 'include';
            push @child_files, $name;
        }
    }

    # Build MOC content
    my $content = "---\n";
    if (defined $parent_name) {
        $content .= "up: \"[[$parent_name]]\"\n";
    }
    $content .= "---\n\n";

    # List child directories first (sub-MOCs)
    for my $child (@child_dirs) {
        $content .= "- [[$child]]\n";
    }

    # Then child files
    for my $child (@child_files) {
        $content .= "- [[$child]]\n";
    }

    # Write the MOC file
    open my $fh, '>', $moc_file or die "Cannot write $moc_file: $!\n";
    print $fh $content;
    close $fh;

    print "MOC: $dirname ($moc_file)\n";

    # Recurse into subdirectories
    for my $child (@child_dirs) {
        process_dir(File::Spec->catfile($dir, $child), $dirname);
    }
}
