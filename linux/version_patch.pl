#!/usr/bin/perl
use strict;


sub patch_file($$$$)
{
	my $filename = shift;
	my $function = shift;
	my $after_line = shift;
	my $media_build_version = shift;
	my $patched;
	my $warning = "VERSION: blindscan drivers:";

	open IN, "$filename" or die "can't open $filename";
	my $is_function;
	my $file;
	my $org_file;
	while (<IN>) {
		$org_file .= $_;
		next if (m/($warning)/);
		$file .= $_;
		if (m/($function)/) {
			$is_function = 1;
			next;
		};
		next if (!$is_function);
		if (/\}/) {
			$is_function--;
			next;
		};
		if (m/\{/) {
			$is_function++;
			next;
		};
		if ($is_function && m/($after_line)/) {
			$file .= "$media_build_version";
			$is_function = 0;
			$patched++;
			next;
		};
	}
	close IN;
	if ($org_file ne $file) {
		open OUT, ">$filename.new" or die "Can't open $filename.new";
		print OUT $file;
		close OUT;

		rename "$filename", "$filename~" or die "Can't rename $filename to $filename~";
		rename "$filename.new", "$filename" or die "Can't rename $filename.new to $filename";
		if ($patched) {
			print "Patched $filename\n";
		} else {
			die "$filename was not patched.\n";
		}
	} else {
			print "$filename was already patched\n";
	}
}

#
# Main
#
open IN, "git_log" or die "can't open git_log";

open IN, "git_rev" or die "can't open git_rev";
my $rev;
$rev.=$_ while (<IN>);
close IN;

if (open IN,".linked_dir") {
	while (<IN>) {
		if (m/^path:\s*(.*)/) {
                    my $dir=$1;
                    my $new_rev = qx(git --git-dir $dir/.git log --pretty=format:'%h' -n 1 );
			if ($new_rev ne $rev) {
				printf("Git rev changed.\n");
				open OUT, ">git_rev";
				print OUT $new_rev;
				close OUT;
				$rev = $new_rev;
			}

			last;
		}
	}
	close IN;
}

$rev =~ s,\",\\\",g;
$rev =~ s,\n,,g;
$rev = "*rev=\"GIT-REV = \\\"$rev\\\";\";";

open IN, "git_tag" or die "can't open git_tag";
my $tag;
$tag.=$_ while (<IN>);
close IN;

if (open IN,".linked_dir") {
	while (<IN>) {
		if (m/^path:\s*(.*)/) {
                    my $dir=$1;
                    my $new_tag = qx(git --git-dir $dir/.git describe --exact-match --tags );
			if ($new_tag ne $tag) {
				printf("Git tag changed.\n");
				open OUT, ">git_tag";
				print OUT $new_tag;
				close OUT;
				$tag = $new_tag;
			}

			last;
		}
	}
	close IN;
}


$tag =~ s,\",\\\",g;
$tag =~ s,\n,,g;
$tag = "*tag=\"GIT-TAG = \\\"$tag\\\";\";";

open IN, "git_branch" or die "can't open git_branch";
my $branch;
$branch.=$_ while (<IN>);
close IN;

if (open IN,".linked_dir") {
	while (<IN>) {
		if (m/^path:\s*(.*)/) {
			my $dir=$1;
                        my $new_branch = qx(git --git-dir $dir/.git rev-parse --abbrev-ref HEAD );
			if ($new_branch ne $branch) {
				printf("Git branch changed.\n");
				open OUT, ">git_branch";
				print OUT $new_branch;
				close OUT;
				$branch = $new_branch;
			}
                        last;
                }
        }
	close IN;
}


$branch =~ s,\",\\\",g;
$branch =~ s,\n,,g;
$branch = "*branch=\"GIT-BRANCH = \\\"$branch\\\";\";";

# Prepare patches message
my $vstrings= "\t$rev\n\t$tag\n\t$branch\n";

# Patch dvbdev
patch_file "drivers/media/dvb-core/dvbdev.c", "dvb_git_versions", "neumo_version_string", $vstrings;

# Patch v4l2-dev
patch_file "drivers/media/v4l2-core/v4l2-dev.c", "dvb_git_versions", "neumo_version_string", $vstrings;
# Patch rc core
patch_file "drivers/media/rc/rc-main.c", "dvb_git_versions", "neumo_version_string", $vstrings;
