#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use FindBin qw($Bin);
use Cwd qw(abs_path);
use File::Basename qw(dirname basename);
use lib "$Bin";
#use block;

my ($if,$ib,$nf,$nb,$ia,$iv,$na,$nv,$pf,$pb,$pa,$pv,$ih,$ph,$size,$out);
GetOptions(
		"if:s" => \$if,
		"ib:s" => \$ib,
		"ia:s" => \$ia,
		"iv:s" => \$iv,
		"nf:s" => \$nf,
		"nb:s" => \$nb,
		"na:s" => \$na,
		"nv:s" => \$nv,

		"pf:s" => \$pf,
		"pb:s" => \$pb,
		"pa:s" => \$pa,
		"pv:s" => \$pv,

		"ih:s" => \$ih,
		"ph:s" => \$ph,

		"s:s" => \$size,
		"o:s" => \$out,
		   );
unless($out && $size && (($if && $nf && $pf) || ($ib && $nb && $pb) || ($ia && $na && $pa) || ($iv && $nv && $pv) || ($ih && $ph))){
	&usage;
	exit;
}

my (@f,@b,@a,@v);
my $ff=my $bb=my $aa=my $vv=0;
if($if){@f=`ls $if |grep -E \"fa\$|gz\$\"|awk '{print \$1}'`;$ff=1;}
if($ib){@b=`ls $ib |grep -E \"fa\$|gz\$\"|awk '{print \$1}'`;$bb=1;}
if($ia){@a=`ls $ia |grep -E \"fa\$|gz\$\"|awk '{print \$1}'`;$aa=1;}
if($iv){@v=`ls $iv |grep -E \"fa\$|gz\$\"|awk '{print \$1}'`;$vv=1;}
#print "@f\n$f[$nf-1]\n";

my $summery=$ff+$bb+$aa+$vv;

if($summery==1){
	if   ($ff==1 && $bb==0 && $aa==0 && $vv==0){my $len=@f;&one($nf,$len,$if,$pf,@f);}
	elsif($ff==0 && $bb==1 && $aa==0 && $vv==0){my $len=@b;&one($nb,$len,$ib,$pb,@b);}
	elsif($ff==0 && $bb==0 && $aa==1 && $vv==0){my $len=@a;&one($na,$len,$ia,$pa,@a);}
	elsif($ff==0 && $bb==0 && $aa==0 && $vv==1){my $len=@v;&one($nv,$len,$iv,$pv,@v);}
}
elsif($summery==2){
	if   ($ff==1 && $bb==1 && $aa==0 && $vv==0){my $len1=@f;my $len2=@b;&two($nf,$nb,$len1,$len2,$if,$ib,$pf,$pb,\@f,\@b);}
	elsif($ff==1 && $bb==0 && $aa==1 && $vv==0){my $len1=@f;my $len2=@a;&two($nf,$na,$len1,$len2,$if,$ia,$pf,$pa,\@f,\@a);}
	elsif($ff==1 && $bb==0 && $aa==0 && $vv==1){my $len1=@f;my $len2=@v;&two($nf,$nv,$len1,$len2,$if,$iv,$pf,$pv,\@f,\@v);}
	elsif($ff==0 && $bb==1 && $aa==1 && $vv==0){my $len1=@b;my $len2=@a;&two($nb,$na,$len1,$len2,$ib,$ia,$pb,$pa,\@b,\@a);}
	elsif($ff==0 && $bb==1 && $aa==0 && $vv==1){my $len1=@b;my $len2=@v;&two($nb,$nv,$len1,$len2,$ib,$iv,$pb,$pv,\@b,\@v);}
	elsif($ff==0 && $bb==0 && $aa==1 && $vv==1){my $len1=@a;my $len2=@v;&two($na,$nv,$len1,$len2,$ia,$iv,$pa,$pv,\@a,\@v);}
}
elsif($summery==3){
	if   ($ff==1 && $bb==1 && $aa==1 && $vv==0){my $len1=@f;my $len2=@b;my $len3=@a;&three($nf,$nb,$na,$len1,$len2,$len3,$if,$ib,$ia,$pf,$pb,$pa,\@f,\@b,\@a);}
	elsif($ff==1 && $bb==1 && $aa==0 && $vv==1){my $len1=@f;my $len2=@b;my $len3=@v;&three($nf,$nb,$nv,$len1,$len2,$len3,$if,$ib,$iv,$pf,$pb,$pv,\@f,\@b,\@v);}
	elsif($ff==1 && $bb==0 && $aa==1 && $vv==1){my $len1=@f;my $len2=@a;my $len3=@v;&three($nf,$na,$nv,$len1,$len2,$len3,$if,$ia,$iv,$pf,$pa,$pv,\@f,\@a,\@v);}
	elsif($ff==0 && $bb==1 && $aa==1 && $vv==1){my $len1=@b;my $len2=@a;my $len3=@v;&three($nb,$na,$nv,$len1,$len2,$len3,$ib,$ia,$iv,$pb,$pa,$pv,\@b,\@a,\@v);}
}

elsif($summery==4){
	my $len1=@f;my $len2=@b;my $len3=@a;my $len4=@v;
	&four($nf,$nb,$na,$nv,$len1,$len2,$len3,$len4,$if,$ib,$ia,$iv,$pf,$pb,$pa,$pv,\@f,\@b,\@a,\@v);
}

#&one($nf,$len,$if,@f)
sub one{
	open O,">$out.txt";
	print O "chosed_data\ttheoretical_size\ttheoretical_percent%\treal_size\treal_percent%\n";
	open O1,">$out.sh";
	open O2,">$out.fa";
	my ($in1,$in2,$in3,$int4,@list)=@_;
	my @rand=&uniqrand($in1,$in2);
	my @percent1=&percent($in1,$int4);
	my ($head,%re);my $sum=0;
	for(my $i=0;$i<@rand;$i++){
		if($size*$percent1[$i]/100-int($size*$percent1[$i]/100)==0){$head=$size*$percent1[$i]/100;}
		elsif($size*$percent1[$i]/100-int($size*$percent1[$i]/100)>=0.5){$head=int($size*$percent1[$i]/100)+1;}
		else{$head=int($size*$percent1[$i]/100);}
		chomp($list[$rand[$i]]);
		$sum=$sum+$head;
		$re{$list[$rand[$i]]}=$head;
		print O1 "perl $Bin/get_reads.pl -i $in3/$list[$rand[$i]] -n $head >>$out.fa\n";
	}

	my $hh;
	if($ih && $ph){
		if($size*$ph/100-int($size*$ph/100)==0){$hh=$size*$ph/100;}
		elsif($size*$ph/100-int($size*$ph/100)>0.5){$hh=int($size*$ph/100)+1;}
		else{$hh=int($size*$ph/100);}
		$sum=$sum+$hh;
		print O1 "perl $Bin/get_reads.pl -i $ih/Homo.fa -n $hh >>$out.fa\n";
	}

	for(my $i=0;$i<@rand;$i++){
		my $d=$re{$list[$rand[$i]]}/$sum*100;
		my $pre=$size*$percent1[$i]/100;
		my $ppp=$percent1[$i];
		print O "$in3/$list[$rand[$i]]\t$pre\t$ppp\t$re{$list[$rand[$i]]}\t$d\n";
	}
	if($ih && $ph){
		my $dh=$hh/$sum*100;
		my $preh=$size*$ph/100;
		print O "$ih/Homo.fa\t$preh\t$ph\t$hh\t$dh\n";		
	}
	close O;
	close O1;
	close O2;
}

#&two($nf,$nb,$len1,$len2,$if,$ib,\@f,\@b)
sub two{
	open O,">$out.txt";
	print O "chosed_data\ttheoretical_size\ttheoretical_percent%\treal_size\treal_percent%\n";
	open O1,">$out.sh";
	open O2,">$out.fa";
	my ($nf,$nb,$lenf,$lenb,$if,$ib,$pf,$pb,$f,$b)=@_;
	my @randf=&uniqrand($nf,$lenf);
	my @randb=&uniqrand($nb,$lenb);
	#my $n=$nf+$nb;
	my @percent1=&percent($nf,$pf);
	my @percent2=&percent($nb,$pb);
	my ($head,%re);my $sum=0;
	for(my $i=0;$i<$nf;$i++){
		if($size*$percent1[$i]/100-int($size*$percent1[$i]/100)==0){$head=$size*$percent1[$i]/100;}
		elsif($size*$percent1[$i]/100-int($size*$percent1[$i]/100)>=0.5){$head=int($size*$percent1[$i]/100)+1;}
		else{$head=int($size*$percent1[$i]/100);}
		chomp($$f[$randf[$i]]);
		$sum=$sum+$head;$re{$$f[$randf[$i]]}=$head;
		print O1 "perl $Bin/get_reads.pl -i $if/$$f[$randf[$i]] -n $head >>$out.fa\n";
	}
	for(my $i=0;$i<$nb;$i++){
		if($size*$percent2[$i]/100-int($size*$percent2[$i]/100)==0){$head=$size*$percent2[$i]/100;}
		elsif($size*$percent2[$i]/100-int($size*$percent2[$i]/100)>=0.5){$head=int($size*$percent2[$i]/100)+1;}
		else{$head=int($size*$percent2[$i]/100);}
		chomp($$b[$randb[$i]]);
		$sum=$sum+$head;$re{$$b[$randb[$i]]}=$head;
		print O1"perl $Bin/get_reads.pl -i $ib/$$b[$randb[$i]] -n $head >>$out.fa\n";
	}

	my $hh;
	if($ih && $ph){
		if($size*$ph/100-int($size*$ph/100)==0){$hh=$size*$ph/100;}
		elsif($size*$ph/100-int($size*$ph/100)>0.5){$hh=int($size*$ph/100)+1;}
		else{$hh=int($size*$ph/100);}
		$sum=$sum+$hh;
		print O1 "perl $Bin/get_reads.pl -i $ih/Homo.fa -n $hh >>$out.fa\n";
	}

	for(my $i=0;$i<@randf;$i++){
		my $d=$re{$$f[$randf[$i]]}/$sum*100;
		my $pre=$size*$percent1[$i]/100;
		my $ppp=$percent1[$i];
		print O "$if/$$f[$randf[$i]]\t$pre\t$ppp\t$re{$$f[$randf[$i]]}\t$d\n";
	}
	for(my $i=0;$i<$nb;$i++){
		my $d=$re{$$b[$randb[$i]]}/$sum*100;
		my $pre=$size*$percent2[$i]/100;
		my $ppp=$percent2[$i];
		print O "$ib/$$b[$randb[$i]]\t$pre\t$ppp\t$re{$$b[$randb[$i]]}\t$d\n";
	}
	if($ih && $ph){
		my $dh=$hh/$sum*100;
		my $preh=$size*$ph/100;
		print O "$ih/Homo.fa\t$preh\t$ph\t$hh\t$dh\n";	
	}
	close O;
	close O1;
	close O2;
}

#&three($nf,$nb,$na,$len1,$len2,$len3,$if,$ib,$ia,\@f,\@b,\@a);
sub three{
	open O,">$out.txt";
	print O "chosed_data\ttheoretical_size\ttheoretical_percent%\treal_size\treal_percent%\n";
	open O1,">$out.sh";
	open O2,">$out.fa";
	my ($nf,$nb,$na,$lenf,$lenb,$lena,$if,$ib,$ia,$pf,$pb,$pa,$f,$b,$a)=@_;
	my @randf=&uniqrand($nf,$lenf);
	my @randb=&uniqrand($nb,$lenb);
	my @randa=&uniqrand($na,$lena);
	my @percent1=&percent($nf,$pf);
	my @percent2=&percent($nb,$pb);
	my @percent3=&percent($na,$pa);
	my ($head,%re);my $sum=0;
	for(my $i=0;$i<@randf;$i++){
		if($size*$percent1[$i]/100-int($size*$percent1[$i]/100)==0){$head=$size*$percent1[$i]/100;}
		elsif($size*$percent1[$i]/100-int($size*$percent1[$i]/100)>=0.5){$head=int($size*$percent1[$i]/100)+1;}
		else{$head=int($size*$percent1[$i]/100);}
		chomp($$f[$randf[$i]]);
		$sum=$sum+$head;$re{$$f[$randf[$i]]}=$head;
		print O1 "perl $Bin/get_reads.pl -i $if/$$f[$randf[$i]] -n $head >>$out.fa\n";
	}
	for(my $i=0;$i<$nb;$i++){
		if($size*$percent2[$i]/100-int($size*$percent2[$i]/100)==0){$head=$size*$percent2[$i]/100;}
		elsif($size*$percent2[$i]/100-int($size*$percent2[$i]/100)>=0.5){$head=int($size*$percent2[$i]/100)+1;}
		else{$head=int($size*$percent2[$i]/100);}
		chomp($$b[$randb[$i]]);
		$sum=$sum+$head;$re{$$b[$randb[$i]]}=$head;
		print O1"perl $Bin/get_reads.pl -i $ib/$$b[$randb[$i]] -n $head >>$out.fa\n";
	}
	for(my $i=0;$i<$na;$i++){
		if($size*$percent3[$i]/100-int($size*$percent3[$i]/100)==0){$head=$size*$percent3[$i]/100;}
		elsif($size*$percent3[$i]/100-int($size*$percent3[$i]/100)>=0.5){$head=int($size*$percent3[$i]/100)+1;}
		else{$head=int($size*$percent3[$i]/100);}
		chomp($$a[$randa[$i]]);
		$sum=$sum+$head;$re{$$a[$randa[$i]]}=$head;
		print O1"perl $Bin/get_reads.pl -i $ia/$$a[$randa[$i]] -n $head >>$out.fa\n";
	}
	
	my $hh;
	if($ih && $ph){
		if($size*$ph/100-int($size*$ph/100)==0){$hh=$size*$ph/100;}
		elsif($size*$ph/100-int($size*$ph/100)>0.5){$hh=int($size*$ph/100)+1;}
		else{$hh=int($size*$ph/100);}
		$sum=$sum+$hh;
		print O1 "perl $Bin/get_reads.pl -i $ih/Homo.fa -n $hh >>$out.fa\n";
	}

	for(my $i=0;$i<@randf;$i++){
		my $d=$re{$$f[$randf[$i]]}/$sum*100;
		my $pre=$size*$percent1[$i]/100;
		my $ppp=$percent1[$i];
		print O "$if/$$f[$randf[$i]]\t$pre\t$ppp\t$re{$$f[$randf[$i]]}\t$d\n";
	}
	for(my $i=0;$i<$nb;$i++){
		my $d=$re{$$b[$randb[$i]]}/$sum*100;
		my $pre=$size*$percent2[$i]/100;
		my $ppp=$percent2[$i];
		print O "$ib/$$b[$randb[$i]]\t$pre\t$ppp\t$re{$$b[$randb[$i]]}\t$d\n";
	}
	for(my $i=0;$i<$na;$i++){
		my $d=$re{$$a[$randa[$i]]}/$sum*100;
		my $pre=$size*$percent3[$i]/100;
		my $ppp=$percent3[$i];
		print O "$ia/$$a[$randa[$i]]\t$pre\t$ppp\t$re{$$a[$randa[$i]]}\t$d\n";
	}
	if($ih && $ph){
		my $dh=$hh/$sum*100;
		my $preh=$size*$ph/100;
		print O "$ih/Homo.fa\t$preh\t$ph\t$hh\t$dh\n";	
	}
	close O;
	close O1;
	close O2;
}

#&four($nf,$nb,$na,$nv,$len1,$len2,$len3,$len4,$if,$ib,$ia,$iv,\@f,\@b,\@a,\@v);
sub four{
	open O,">$out.txt";
	print O "chosed_data\ttheoretical_size\ttheoretical_percent%\treal_size\treal_percent%\n";
	open O1,">$out.sh";
	open O2,">$out.fa";
	my ($nf,$nb,$na,$nv,$lenf,$lenb,$lena,$lenv,$if,$ib,$ia,$iv,$pf,$pb,$pa,$pv,$f,$b,$a,$v)=@_;
	my @randf=&uniqrand($nf,$lenf);
	my @randb=&uniqrand($nb,$lenb);
	my @randa=&uniqrand($na,$lena);
	my @randv=&uniqrand($nv,$lenv);
	my @percent1=&percent($nf,$pf);
	my @percent2=&percent($nb,$pb);
	my @percent3=&percent($na,$pa);
	my @percent4=&percent($nv,$pv);
	my ($head,%re);my $sum=0;
	for(my $i=0;$i<$nf;$i++){
		if($size*$percent1[$i]/100-int($size*$percent1[$i]/100)==0){$head=$size*$percent1[$i]/100;}
		elsif($size*$percent1[$i]/100-int($size*$percent1[$i]/100)>=0.5){$head=int($size*$percent1[$i]/100)+1;}
		else{$head=int($size*$percent1[$i]/100);}
		chomp($$f[$randf[$i]]);
		$sum=$sum+$head;$re{$$f[$randf[$i]]}=$head;
		print O1 "perl $Bin/get_reads.pl -i $if/$$f[$randf[$i]] -n $head >>$out.fa\n";
	}

	for(my $i=0;$i<$nb;$i++){
		if($size*$percent2[$i]/100-int($size*$percent2[$i]/100)==0){$head=$size*$percent2[$i]/100;}
		elsif($size*$percent2[$i]/100-int($size*$percent2[$i]/100)>=0.5){$head=int($size*$percent2[$i]/100)+1;}
		else{$head=int($size*$percent2[$i]/100);}
		chomp($$b[$randb[$i]]);
		$sum=$sum+$head;$re{$$b[$randb[$i]]}=$head;
		print O1"perl $Bin/get_reads.pl -i $ib/$$b[$randb[$i]] -n $head >>$out.fa\n";
	}

	for(my $i=0;$i<$na;$i++){
		if($size*$percent3[$i]/100-int($size*$percent3[$i]/100)==0){$head=$size*$percent3[$i]/100;}
		elsif($size*$percent3[$i]/100-int($size*$percent3[$i]/100)>=0.5){$head=int($size*$percent3[$i]/100)+1;}
		else{$head=int($size*$percent3[$i]/100);}
		chomp($$a[$randa[$i]]);
		$sum=$sum+$head;$re{$$a[$randa[$i]]}=$head;
		print O1"perl $Bin/get_reads.pl -i $ia/$$a[$randa[$i]] -n $head >>$out.fa\n";
	}

	for(my $i=0;$i<$nv;$i++){
		if($size*$percent4[$i]/100-int($size*$percent4[$i]/100)==0){$head=$size*$percent4[$i]/100;}
		elsif($size*$percent4[$i]/100-int($size*$percent4[$i]/100)>=0.5){$head=int($size*$percent4[$i]/100)+1;}
		else{$head=int($size*$percent4[$i]/100);}
		chomp($$v[$randv[$i]]);
		$sum=$sum+$head;$re{$$v[$randv[$i]]}=$head;
		print O1"perl $Bin/get_reads.pl -i $iv/$$v[$randv[$i]] -n $head >>$out.fa\n";
	}

	my $hh;
	if($ih && $ph){
		if($size*$ph/100-int($size*$ph/100)==0){$hh=$size*$ph/100;}
		elsif($size*$ph/100-int($size*$ph/100)>0.5){$hh=int($size*$ph/100)+1;}
		else{$hh=int($size*$ph/100);}
		$sum=$sum+$hh;
		print O1 "perl $Bin/get_reads.pl -i $ih/Homo.fa -n $hh >>$out.fa\n";
	}

	for(my $i=0;$i<@randf;$i++){
		my $d=$re{$$f[$randf[$i]]}/$sum*100;
		my $pre=$size*$percent1[$i]/100;
		my $ppp=$percent1[$i];
		print O "$if/$$f[$randf[$i]]\t$pre\t$ppp\t$re{$$f[$randf[$i]]}\t$d\n";
	}
	for(my $i=0;$i<$nb;$i++){
		my $d=$re{$$b[$randb[$i]]}/$sum*100;
		my $pre=$size*$percent2[$i]/100;
		my $ppp=$percent2[$i];
		print O "$ib/$$b[$randb[$i]]\t$pre\t$ppp\t$re{$$b[$randb[$i]]}\t$d\n";
	}
	for(my $i=0;$i<$na;$i++){
		my $d=$re{$$a[$randa[$i]]}/$sum*100;
		my $pre=$size*$percent3[$i]/100;
		my $ppp=$percent3[$i];
		print O "$ia/$$a[$randa[$i]]\t$pre\t$ppp\t$re{$$a[$randa[$i]]}\t$d\n";
	}
	for(my $i=0;$i<$nv;$i++){
		my $d=$re{$$v[$randv[$i]]}/$sum*100;
		my $pre=$size*$percent4[$i]/100;
		my $ppp=$percent4[$i];
		print O "$iv/$$v[$randv[$i]]\t$pre\t$ppp\t$re{$$v[$randv[$i]]}\t$d\n";
	}
	if($ih && $ph){
		my $dh=$hh/$sum*100;
		my $preh=$size*$ph/100;
		print O "$ih/Homo.fa\t$preh\t$ph\t$hh\t$dh\n";
	}
	close O;
	close O1;
	close O2;
}

system("sh $out.sh");

sub uniqrand{
	my @in=@_;
	my %h;my @back;my $rf;
	if($in[0]==$in[1]){
		for(my $i=0;$i<$in[1];$i++){
			push @back,$i;
		}
	}
	else{
		if($in[0]<$in[1]){
			for(my $i=1;$i<=$in[0];){
				my $rf=int(rand($in[1]));
				if(exists $h{$rf}){;}
				else{
					$h{$rf}++;$i++;
					push @back,$rf;
				}
			}
		}
	}
	return @back;
}

#&percent($nf,100)
sub percent{
	my @in=@_;
	my $n=$in[0];
	my @back;
	my $flag=0;
	until($flag==1){
		my $sum=0;
		my (%r,$r);
		for(my $i=1;$i<=$n;){
			$r=rand($in[1]);
			if($r>0){
				$r{$i}=$r;
				$sum=$sum+$r;
				$i++;
			}
		}
		my $count=0;
		foreach my $k (keys %r) {
			if($r{$k}*$in[1]/$sum>0.1){$count++;}
		}
		if($count==$n){
			$flag=1;
			foreach my $k (keys %r) {
				push @back,$r{$k}*$in[1]/$sum;
			}
		}
	}
	return @back;
}

sub execute{
	my $cmd = shift;
	print "$cmd\n";
	system($cmd);
}

sub usage{
	print STDERR "\e[;33;1m
		DESCRIPTION 
			Simulated community structure
		USAGE
			perl Simulated_community_structure.pl
		PARAMETERS
			-if <s> Fungus database path
			-nf <n> Number of Fungus chosed (must if -if be defined)
			-pf <n> Percentage of Fungus % (must if -if be defined)

			-ib <s> Bacteria database path
			-nb <n> Number of Bacteria chosed(must if -ib be defined)
			-pb <n> Percentage of Bacteria % (must if -ib be defined)

			-ia <s> Archaebacteria database path
			-na <n> Number of Archaebacteria chosed(must if -ia be defined)
			-pa <n> Percentage of Archaebacteria % (must if -ia be defined)

			-iv <s> Virus database path
			-nv <n> Number of Virus chosed(must if -iv be defined)
			-pv <n> Percentage of Virus % (must if -iv be defined)

			-ih <s> Homo database Homo.fa path 
			-ph <s> Percentage of Homo % (must if -ih be defined)

			-s  <n>	Size or number of reads
			-o  <s> Out Prefix
		AUTHOR:  CTR
		2018.06.04:Add percentage and homo \e[0m
		###################################################
		1.If the -s below than 1000, this script may be report error, 
		  for the minimum percent is 0.1%, so 1000*0.1%=1, if -s below than 1000, 
		  the number of reads chose from .fa will less than 1
		2.The number of chosed .fa files should not be over than total,
		  if Fungus database path have 40 .fa files, then -nf should not be over than 40
		3.If a .fa have total 20 reads, script can rand chose more than 20 reads for 
		  repeat extraction reads
		4.The summery of real_size in output.txt will not equal the -s, for the 
		  theoretical_size are not integer
		###################################################
		\n";
}

