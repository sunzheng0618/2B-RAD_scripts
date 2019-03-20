#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use FindBin qw($Bin);
use Cwd qw(abs_path);
use File::Basename qw(dirname basename);
use lib "$Bin";
#use block;

my ($in,$num);
GetOptions(
        "i:s" => \$in,
		"n:s" => \$num,
        );
unless($in && $num){
        &usage;
        exit;
}

my (%h1,%h2);
my $id;
my $cnt=0;
if($in=~/\.gz$/){open I,"gzip -dc $in |";}
else{open I,"$in";}
while(<I>){
	chomp;
	my @t=split(/\s+/);
	if(/>/){$id=$_;}
	else{
		$h1{$cnt}=$id;
		$h2{$cnt}=$_;
		$cnt++;
	}
}
close I;

for(my $i=$num;$i>0;$i--){
	my $r=int(rand($cnt));
	print "$h1{$r}\n$h2{$r}\n"; 
}

sub usage{
	print STDERR "
	DESCRIPTION
	USAGE
	PARAMETERS
		-i  <s> Input File fa
		-n  <s> Num
	AUTHOR:  CTR
	\n";
}
