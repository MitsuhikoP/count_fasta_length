#!/usr/bin/perl
# copyright (c) 2016 Mitsuhiko Sato. All Rights Reserved.
# Mitsuhiko Sato ( E-mail: mitsuhikoevolution@gmail.com )
use strict;
use warnings;
use Getopt::Long;
die "USAGE:perl [--verbose|-v] count_fasta_length.pl file.fasta [file2.fasta...]\n" if(@ARGV < 1);

my $verbose;

GetOptions('verbose|v' => \$verbose);
    
foreach my $arg(@ARGV){
    open(IN,$arg) or die "$!";
    if($arg =~ /\.gz$/){
        close(IN);
        open(IN,"gzip -dc $arg |") or die "$!";
    }

    my %seqs;
    my $gene_name;
    while (my $line=<IN>){
        chomp($line);
        if($line =~ /^>(\S+)/){
            $gene_name=$1;
            $seqs{$gene_name}="";
        }else{
            $seqs{$gene_name}=$seqs{$gene_name}.$line;
        }
    }
    close(IN);

    my $num_contig=scalar(keys(%seqs));

    my $len;
    my $total=0;
    my $max=0;
    my @leng;
    foreach my $chrom ( sort keys(%seqs) ){
        $len=length($seqs{$chrom});
        push(@leng, $len);
        $total=$total+$len;
        if($len > $max){
            $max=$len;
        }
        if($verbose){
            print "$chrom\t$len\n";
        }
    }
    my @length_sorted=sort{$b <=> $a} @leng;
    my $n50_sum=0;
    my $n50=0;
    my $l50=0;

    for(my $i=0; $i < @length_sorted; $i++){
        $n50_sum += $length_sorted[$i];
        $l50++;
        if($n50_sum >= $total/2){
            $n50 = $i;
            last;
        }
    }

    print "$arg\ttotal\t$total\tmax\t$max\tnum_contig\t$num_contig\tN50\t",$length_sorted[$n50],"\tL50\t$l50\n";

}
