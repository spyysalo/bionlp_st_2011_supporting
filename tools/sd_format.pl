#!/usr/bin/perl

# does a little cosmetic conversion for the stanford format:.
# (nsubj foo_4 bar_3) =>
# nsubj(foo_5, bar_4)

#strip introductory comments and blank line(s)
$line = <STDIN>;
$introduction =1;
while ( defined($line) and $introduction>0 ){
	if ($line =~ /^(#|\n)/) {
		#Skip comment or blank lines
		#print "SKIP: $line";
		$line = <STDIN>;
	}else{
		$introduction =0;
	}
}#While introduction
	
while ( defined($line) ) {
	#print "Line: $line";
	#Strip Comments
	if ( $line =~ /\((\S+) (\S+)_(\d+) (\S+)_(\d+)\)/) {
    $output = "$1($2-" . ($3+1) . ", $4-" . ($5+1) . ")\n";
    print $output;
  }else {
    if (!($line =~ /<c>/ or $line =~ /^\n/)) {
      print STDERR "Warning: unexpected format: $. $_\n";
    }
    if ($line =~ /^\n/){
	    print "$line";
	  }
  }
  $line = <STDIN>;
}#while input
