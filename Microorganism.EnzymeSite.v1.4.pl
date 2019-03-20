#!/usr/bin/perl -w
use strict;
use Getopt::Long;

my ($input,$prefix,$site,$quality,$percent,$qbase,$adda,$type);
GetOptions(
        "i:s" => \$input,
        "p:s" => \$prefix,
        "s:s" => \$site,
	"q:s" => \$quality,
        "e:s" => \$percent,
        "b:s" => \$qbase,
	"a:s" => \$adda,
	"t:s" => \$type,
        );

unless( $input && $prefix && $type){
    &usage;
    exit;
}
unless( $site && $site <= 16 ){
    $site = 1;
    print STDERR "-s 1\n";
}

$qbase   ||= 33;
$percent ||= 80;
$quality ||= 30;
my $number =  0;

my @site = ();
if( 1 == $site ){#CspCI
    @site = (
            '[AGCT]{11}CAA[AGCT]{5}GTGG[AGCT]{10}',
            '[AGCT]{10}CCAC[AGCT]{5}TTG[AGCT]{11}',
            );
}elsif( 2 == $site ){#AloI
    @site = (
            '[AGCT]{7}GAAC[AGCT]{6}TCC[AGCT]{7}',
            '[AGCT]{7}GGA[AGCT]{6}GTTC[AGCT]{7}',
            );
}elsif( 3 == $site ){#BsaXI
    @site = (
            '[AGCT]{9}AC[AGCT]{5}CTCC[AGCT]{7}',
            '[AGCT]{7}GGAG[AGCT]{5}GT[AGCT]{9}',
            );
}elsif( 4 == $site ){#BaeI
    @site = (
            '[AGCT]{10}AC[AGCT]{4}GTA[CT]C[AGCT]{7}',
            '[AGCT]{7}G[AG]TAC[AGCT]{4}GT[AGCT]{10}',
            );
}elsif( 5 == $site ){#BcgI
    @site = (
            '[AGCT]{10}CGA[AGCT]{6}TGC[AGCT]{10}',
            '[AGCT]{10}GCA[AGCT]{6}TCG[AGCT]{10}',
            );
}elsif( 6 == $site ){#CjeI
    @site = (
            '[AGCT]{8}CCA[AGCT]{6}GT[AGCT]{9}',
            '[AGCT]{9}AC[AGCT]{6}TGG[AGCT]{8}',
            );
}elsif( 7 == $site ){#PpiI
    @site = (
            '[AGCT]{7}GAAC[AGCT]{5}CTC[AGCT]{8}',
            '[AGCT]{8}GAG[AGCT]{5}GTTC[AGCT]{7}',
            );
}elsif( 8 == $site ){#PsrI
    @site = (
            '[AGCT]{7}GAAC[AGCT]{6}TAC[AGCT]{7}',
            '[AGCT]{7}GTA[AGCT]{6}GTTC[AGCT]{7}',
            );
}elsif( 9 == $site ){#BplI
    @site = (
            '[AGCT]{8}GAG[AGCT]{5}CTC[AGCT]{8}',
            '[AGCT]{8}GAG[AGCT]{5}CTC[AGCT]{8}',
            );
}elsif( 10 == $site ){#FalI
    @site = (
            '[AGCT]{8}AAG[AGCT]{5}CTT[AGCT]{8}',
            '[AGCT]{8}AAG[AGCT]{5}CTT[AGCT]{8}',
            );
}elsif( 11 == $site ){#Bsp24I
    @site = (
            '[AGCT]{8}GAC[AGCT]{6}TGG[AGCT]{7}',
            '[AGCT]{7}CCA[AGCT]{6}GTC[AGCT]{8}',
            );
}elsif( 12 == $site ){#HaeIV
    @site = (
            '[AGCT]{7}GA[CT][AGCT]{5}[AG]TC[AGCT]{9}',
            '[AGCT]{9}GA[CT][AGCT]{5}[AG]TC[AGCT]{7}',
            );
}elsif( 13 == $site ){#CjePI
    @site = (
            '[AGCT]{7}CCA[AGCT]{7}TC[AGCT]{8}',
            '[AGCT]{8}GA[AGCT]{7}TGG[AGCT]{7}',
            );
}elsif( 14 == $site ){#Hin4I
    @site = (
            '[AGCT]{8}GA[CT][AGCT]{5}[GAC]TC[AGCT]{8}',
            '[AGCT]{8}GA[CTG][AGCT]{5}[AG]TC[AGCT]{8}',
            );
}elsif( 15 == $site ){#AlfI
    @site = (
            '[AGCT]{10}GCA[AGCT]{6}TGC[AGCT]{10}',
            '[AGCT]{10}GCA[AGCT]{6}TGC[AGCT]{10}',
            );
}elsif( 16 == $site ){#BslFI
    @site = (
            '[AGCT]{6}GGGAC[AGCT]{14}',
            '[AGCT]{14}GTCCC[AGCT]{6}',
            );
}

my (@name,@fasta);

if($type==1){
	if( $input =~ /\.gz$/ ){
		open FAS,"gzip -dc $input | " or die "Cannot Open $input\n";
	}else{
		open FAS,"$input" or die "$input\n";
	}
	my $head = (<FAS>);
	close FAS;
	my ($seq);
	open OUT,"> $prefix.fa" or die "Cannot Open $prefix.fa\n";
	if($head=~/^\@/){
		if( $input =~ /\.gz$/ ){
			open FAS,"gzip -dc $input | " or die "Cannot Open $input\n";
		}else{
			open FAS,"$input" or die "$input\n";
		}	
		my ($name,$qua,$seq);
		my $cnt=0;
		while(<FAS>){
			chomp;
			if(/^@/ && ($cnt==0 || $cnt==4)){
				if($cnt>0){
					&Enzyme($name,$seq,$qua);
				}
				$name=$_;
				$cnt=0;
			}elsif($cnt==1){
				$seq = uc($_);
			}elsif($cnt==2){	
				unless($_=~/^\+/){
					print "Error\n"
				}
			}elsif($cnt==3){
				$qua=$_;
			}
			$cnt++;
		}
		&Enzyme($name,$seq,$qua);
	}elsif($head=~/^\>/){
		if( $input =~ /\.gz$/ ){
			open FAS,"gzip -dc $input | " or die "Cannot Open $input\n";
		}else{
			open FAS,"$input" or die "$input\n";
		}
		while(<FAS>){
			chomp;
			if(/^>(\S+)/){
				push @name,$1;
				next unless( $seq );
				push @fasta,$seq;
				$seq = "";
			}else{
				$seq .= uc($_);
			}
		}
		push @fasta,$seq;
		&IIBRAD;				
	}
	close FAS;
	close OUT;

}elsif($type==2){
	open DIR,"$input" or die "Cannot Open $input\n";
	open OUT,">$prefix.fa"  or die "Cannot Open $prefix.fa\n";
	while(<DIR>){
		chomp;
		my $num=(split(/\_/,(split(/\//,$_))[-1]))[0]."_".(split(/\_/,(split(/\//,$_))[-1]))[1];
		my $species = "";
		my $leng = 0;
		my $cnt = 0;
		$number = 0;
		if( $_ =~ /\.gz/ ){
			open FAS,"gzip -dc $_ | " or die "Cannot Open $_\n";
		}else{
			open FAS,"$_" or die "$_\n";
		}

		@name = @fasta=();
		my $seq ;
		while(my $word = <FAS> ){
			chomp($word);
			if($word=~/^>/){
				$species ||= (split(/\s+/,$word))[1].".".(split(/\s+/,$word))[2].".".(split(/\s+/,$word))[3];
				next unless( $seq );
				push @fasta,$seq;
				$seq = "";
			}else{
				$leng += length($word);
				$seq .= uc($word);
			}
		}

		$leng=sprintf "%.2f",$leng/1000000 ;
		$leng= $leng ."Mbp";
		push @fasta,$seq;

		foreach my $j( 0 .. $#fasta ){
			$site=join "\|" ,@site;
			 while( $fasta[$j] =~ /($site)/g ){
			        my $pos = pos($fasta[$j]);
			        my $tmpl= length($1);
			        $cnt ++ ;
        			pos($fasta[$j])=$pos-$tmpl+1;
    			}
		}

		my $id = "$species"."("."$num".",$leng,$cnt".")" ;
		foreach my $j( 0 .. $#fasta){
			my $enzymeseq = &ENZ($id,$fasta[$j],$site);
			print OUT "$enzymeseq";
                }
	}
}else{

	print "Type is error\n";

}

sub Enzyme{
    my $id       = shift;
    my $vector   = shift;
    my $qual     = shift;
    $id=~s/^@/>/g;
    if($vector =~ /($site[0])/g){
		my $pos = pos($vector);
		my $tmpl= length($1);
		my $tag = substr($vector,$pos-$tmpl,$tmpl);
		my $qual = substr($qual,$pos-$tmpl,$tmpl);
		my @array = split //,$qual;
		my $count = 0;
		foreach my $i( @array ){
			next unless( ord($i) >= $quality + $qbase );
			$count ++;
		}
		if( $count >= scalar(@array) * $percent / 100 ){
				print OUT "$id\n$tag\n";
		}
	}elsif($vector =~ /($site[1])/g){
		my $pos = pos($vector);
		my $tmpl= length($1);
		my $tag = substr($vector,$pos-$tmpl,$tmpl);
		my $qual = substr($qual,$pos-$tmpl,$tmpl);
		my @array = split //,$qual;
		my $count = 0;
		foreach my $i( @array ){
			next unless( ord($i) >= $quality + $qbase );
			$count ++;
		}
		if( $count >= scalar(@array) * $percent / 100 ){
			print OUT "$id\n$tag\n";
		}
	}
}

sub IIBRAD{
        foreach my $j( 0 .. $#name ){
	    $site = join "\|" , @site;
            my $enzymeseq = &ENZ($name[$j],$fasta[$j],$site);
	    print OUT "$enzymeseq";
        }
}

sub ENZ{
    my $id     = shift;
    my $vector = shift;
    my $match  = shift;
    my $print = "";
    my $pos1=0;
    while( $vector =~ /($match)/g ){
        my $pos = pos($vector);
        my $tmpl= length($1);
        my $tag = substr($vector,$pos-$tmpl,$tmpl);

        $number ++;
        $pos1=$pos;
        $pos=$pos-$tmpl+1;
        $print .= ">" . (join "-",($id,$number,$pos) ) . "\n";
        if( $adda ){
            $print .= $tag . "A" x 67 . "\n";
        }else{
            $print .= $tag . "\n";
        }
        pos($vector)=$pos;
    }
    return $print;
}


sub usage{
    print STDERR "\e[0m
    USAGE
        perl Microorganism.EnzymeSite.pl -i <in.fq> -p <out.prefix> -s <site>
    OPTIONS
        -i  <s> genome sequence in fastq format (.gz supported)
        -p  <s> output prefix
        -q  <n> quality threshold [30]
        -e  <n> percentage of high quality [80]
        -b  <n> Phred base [33]
	-a  <a> add poly-A for SOAP2 2bwt-builder [not setting for TRUE]
	-t  <i> Type of data (1:Genome File,2:Genome File list;If the input file is .fa, then -t 1 must be defined.)
        -s  <i> choose target restriction site [1]
	ID_Name		Cutting_Frequency	Tag_length	
	[1]CspCI		8192				33
	[2]AloI			8192				27
	[3]BsaXI		2048				27
	[4]BaeI			4096				28
	[5]BcgI			2048				32
	[6]CjeI			512				28
	[7]PpiI			8192				28
	[8]PsrI			8192				27
	[9]BplI			4096				27
	[10]FalI		4096				27
	[11]Bsp24I		2048				27
	[12]HaeIV		1024				27
	[13]CjePI		512				27
	[14]Hin4I		512				27
	[15]AlfI		4096				32
	[16]BslFI		512				21
    VERSION 1.0 2017-11-14
    AUTHOR  Yang Xianwei Sun Zheng Jia Ruikai\n"
}

