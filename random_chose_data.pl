
#open O1,">@ARGV[0].rand";
my %h;
for(my $i=1;$i<=@ARGV[0];){
	my $r=int(rand(4372372));
	if(exists $h{$r} || $r==0){$i=$i;}
	else{$h{$r}++;$i++;}#print O1 "$r\n";}
}

my $count;
my $j=0;
open I,"<@ARGV[1]";
open O,">@ARGV[1].@ARGV[0].@ARGV[2]";
while(<I>){
	chomp;
	my @t=split(/\s+/);	
	if(/>/){
		$count++;
		if(exists $h{$count}){$j=1;print O "$_\n";}
		else{$j=0;}
	}
	else{
		if($j==1){
			print O "$_\n";
		}
	}
}
