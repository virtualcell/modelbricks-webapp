#!/usr/bin/perl
use strict;
use  warnings;
use   utf8;
use XML::Tidy;
use 5.010;
use XML::LibXML;
use XML::Writer;
use HTML::Strip;

my @vcid;
my @metaids;
my $metaid;
my $modelName;
my $label = "NULL";
my $vcid2;
my $text;
my $outputfile;

my $filename = $ARGV[0];
open my $fh, '<', $filename or die $!;
 
my $tidy_obj = XML::Tidy->new('filename' => $filename);
   $tidy_obj->tidy();
   $filename =~ s{\.[^.]+$}{};
my $bettername=$filename."_formatted.xml";
$tidy_obj->write('filename' => $bettername);

open(INFILE, "<", $bettername);

while(my $line = <INFILE>)
{
    # find BioModel name
    if ($line=~/BioModel Name/) {
        $line =~/\"(.*?)\"/;
        $modelName = $1;
        $outputfile=$modelName."_annotations.xml";
    }
    elsif ($line=~/metaid_/ && $line =~/vcid/) {
        #find vcid, metaid matches
        $line =~/metaid_(.*?)\" \//;
        my $match = $1;
        $match=~s/\" vcid=\"/ /;
        my @ids = split /\s+/, $match;
        my $first = shift @ids;
        my $vcid_name=join(' ',@ids);
        push @vcid, $vcid_name;
        push @metaids, $first;
    }
    elsif ($line=~/level2\/version4\/_/ && $line =~/vcid/) {
        #find vcid, metaid matches
        $line =~/level2\/version4\/_(.*?)\" \//;
        my $match = $1;
        $match=~s/\" vcid=\"/ /;
        my @ids = split ' ', $match;
        push @vcid, $ids[1];
        push @metaids, $ids[0];
    }
    elsif ($line=~/level2\/version3\/_/ && $line =~/vcid/) {
        #find vcid, metaid matches
        $line =~/level2\/version3\/_(.*?)\" \//;
        my $match = $1;
        $match=~s/\" vcid=\"/ /;
        my @ids = split ' ', $match;
        push @vcid, $ids[1];
        push @metaids, $ids[0];
    }
    elsif ($line=~/level3\/version1\/_/ && $line =~/vcid/) {
        #find vcid, metaid matches
        $line =~/level3\/version1\/_(.*?)\" \//;
        my $match = $1;
        $match=~s/\" vcid=\"/ /;
        my @ids = split ' ', $match;
        push @vcid, $ids[1];
        push @metaids, $ids[0];
    }
}

my $writer = XML::Writer->new(OUTPUT => 'self', DATA_MODE => 1, DATA_INDENT => 2, );
$writer->xmlDecl('UTF-8');
$writer->startTag('BioModel', name => $modelName);

seek(INFILE,0,0);
while(my $line = <INFILE>)
{
    # find metaid, uri pairs
    if ($line=~/level2\/version4\/_/ and $line=~/about/)
    {
        $label = "RDF";
        $line =~/level2\/version4\/_(.*?)\"/;
        $metaid = $1;
        for my $i (0 .. $#metaids)
        {
            if ($metaid eq $metaids[$i]){
                $metaid=$vcid[$i];
            }
        }
    }
    elsif ($line=~/level2\/version3\/_/ and $line=~/about/)
    {
        $label = "RDF";
        $line =~/level2\/version3\/_(.*?)\"/;
        $metaid = $1;
        for my $i (0 .. $#metaids)
        {
            if ($metaid eq $metaids[$i]){
                $metaid=$vcid[$i];
            }
        }
    }
    elsif ($line=~/level3\/version1\/_/ and $line=~/about/)
    {
        $label = "RDF";
        $line =~/level3\/version1\/_(.*?)\"/;
        $metaid = $1;
        for my $i (0 .. $#metaids)
        {
            if ($metaid eq $metaids[$i]){
                $metaid=$vcid[$i];
            }
        }
    }
    elsif ($line=~/metaid/ and $line=~/about/)
    {
        $label = "RDF";
        $line =~/metaid_(.*?)\"/;
        $metaid = $1;
        for my $i (0 .. $#metaids)
        {
            if ($metaid eq $metaids[$i]){
                $metaid=$vcid[$i];
            }
        }
    }
    elsif (defined($line) && $line=~/miriam/ && $label eq "RDF") {
        $line =~/miriam\:(.*?)\"/;
        my $web = "http://identifiers.org/".$1;
        $writer->startTag('url', name => $metaid);
        $writer->characters($web);
        $writer->endTag('url');
    }
    
    elsif (defined($line) && $line=~/identifiers/ && $label eq "RDF") {
        $line =~/=\"(.*?)\"/;
        my $web = $1;
        $writer->startTag('url', name => $metaid);
        $writer->characters($web);
        $writer->endTag('url');
    }
    
    elsif (defined($line) && $line=~/nonrdfAnnotation vcid/) {
        $line =~/vcid=\"(.*?)\"/;
        $vcid2 = $1;
        $label = "non-RDF";
    }
    elsif (defined($line) && $line=~/\<freetext\>/ && $label eq "non-RDF") {
        $label = "HTML";
    }
    elsif (defined($line) && $line=~/\<\/freetext\>/ && $label eq "HTML") {
        $writer->startTag('text', name => $vcid2);
        $writer->characters($text);
        $writer->endTag('text');
        $text="";
        $label = "non-RDF";
    }
    elsif (defined($line) && $label eq "HTML"){
        my $hs = HTML::Strip->new();
        my $clean_text = $hs->parse($line);
        my $clean_text2 = $hs->parse($clean_text);
        $clean_text2 =~ s/^\s+|\s+$//g;
        $hs->eof;
        $text=$text.$clean_text2." ";
    }
}
close (INFILE);

$writer->endTag('BioModel');
my $xml = $writer->end();
open(FH, '>', $outputfile) or die $!;
print FH $xml;
close(FH);
