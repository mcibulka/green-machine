#!/usr/bin/perl
#***************************************************************************************************************
#
#	File Name: outGM.pl
#
#	Author: Matthew Cibulka (0664008)  
#
#	Date Created: Wednesday, February 9, 2011
#	Last Updated: Friday, February 18, 2011
#     
#	Summary:
#   	This is the output program for the Green Machine project.  It will read the specified CSV file and 
#		dispay either a Statistical or Full report of the data.
#
#	Command Line Parameters:
#   	$ARGV[0] = name of the input file containing the car's information
#	 	$ARGV[1] = type of currency and real number format used 
#	    	- 'NA' for North America (dollars and period)
#	     	- 'EU' for European Union (euros and comma)
#		$ARGV[2] = Type of output
#	    	- 'S' for a full statistical report
#	    	- 'F' for a full report	
#
#	Other Concerns:
#		This program was coded in Eclipse, my apologies if the code indents do not line up. :(	
#
#**************************************************************************************************************
use strict;
use warnings;
use Text::CSV;

#  Command Line Arguments
my $fileName = $ARGV[0];
my $currency = $ARGV[1];
my $report = $ARGV[2];

#  Read CSV File
my $csvObj;
my $lineCount = 0;
my $fieldTitles;
my @fields;

#  Totals
my $totPur = 0;	
my $totLitGas = 0;
my $totCoGas = 0;
my $totFuelEff = 0;

#  Averages
my $avCoLit = 0;
my $avPurCo = 0;
my $avFuelEff = 0;

#  Fuel Efficiency Calculation
my $preOdom = 0;
my $currOdom = 0;
my $currLitGas = 0;
my $fuelEff = 0;


open (CSVFH, $fileName) or die "An error has occurred, $fileName was unable to open.\n$!";
   #  CSVFH is the file handler
    
print "\n\nGreen Machine Output\n";
print "====================\n\n";
	
	
#  Set field separator based on currency request
if ($currency eq 'NA') {
	$csvObj = Text::CSV->new ({sep_char => ","});
}
elsif ($currency eq 'EU') {
	$csvObj = Text::CSV->new ({sep_char => ";"});
}

while (my $record = <CSVFH>) 
{
	$lineCount++;
	
	if ($lineCount == 1) {		#  skip line 1
		$fieldTitles = $record;
	}
   	elsif ($lineCount > 1)
   	{
   		if ($csvObj->parse($record)) 
   		{
      		@fields = $csvObj->fields();

			#  substitue a comma for a period
			$fields[3] =~ s/,/./;
            $fields[4] =~ s/,/./;
            $fields[5] =~ s/,/./;
             
            $currOdom = $fields[2];
            $currLitGas = $fields[3];
                        
            #  calculate fuel efficiency
            if ($lineCount == 2) {		#  first line is field titles, data begins on second
            	$preOdom = $fields[2];
            }
            elsif ($lineCount >= 3)		#  cannot calculate fuel efficiency unless there is a previous odometer reading
            {	
            	$fuelEff = ($currLitGas * 100) / ($currOdom - $preOdom);
            	
            	$preOdom = $currOdom;           		
            }
            else {
            	print "Cannot calculate Fuel Efficiency, not enough data.";
            	exit (0);
            }
                  
            $totLitGas = $totLitGas + $fields[3]; 
     	 	$totCoGas = $totCoGas + $fields[5];
     	 	$totFuelEff = $totFuelEff + $fuelEff;
     	 	    	 	
     	 	#  print each line if full report is requested
     	 	if ($report eq 'F') 
     	 	{
     	 		if ($lineCount == 2) {
     	 			print "Full Report for \"$fileName\":\n";
     	 		}
     	 		
     	 		#  Field Correspondances:
     	 		#  Date   Time   Odometer Reading   Litres of Gas Purchased   Coster Per Litre of Gas   Payment
     	 		my $fullLine = sprintf ("%10s %10s %10s %10.3f %10.3f %10.2f",
     	 			$fields[0], $fields[1], $fields[2], $fields[3], $fields[4], $fields[5]);
     	 			
     	 		if ($currency eq 'EU') {
     	 			$fullLine =~ s/\./,/g;  #  '\' needed before '.' because it is a metacharacter						
     	 		}							#  'g' (global) flag signals to substitute every occurance in string
     	 		print "$fullLine";
     	 		
     	 		if ($lineCount == 2) {		#  first line of data, no totals or fuel efficiency tabulated yet
     	 			print "\n";
     	 		}
     	 		elsif ($lineCount >= 3) 	#  can now calculate fuel efficiency and totals
     	 		{
     	 			my $totals = sprintf ("%10.2f %10.2f %10.2f\n", $fuelEff, $totLitGas, $totCoGas);
     	 			
     	 			if ($currency eq 'EU') {
     	 				$totals =~ s/\./,/g;
     	 			}			
     	 			print "$totals";
     	 		}
     	 	}
     	 	$totPur++;
   		} 
   		else {
      		my $error = $csvObj->error_input;
      		print "Failed to parse line: $error";
   		}
    }
    else {
    	print "Line Count Error. Line Count = $lineCount";
    }
}

#  Display Statistical Report
if ($report eq 'S')	
{
	print "Statistical Report for \"$fileName\":\n";
	$avCoLit = $totLitGas / $totPur; 
	$avPurCo = $totCoGas / $totPur;
	$avFuelEff = $totFuelEff / ($totPur - 1);		#  subtract 1 because fuel efficiency is calculated starting
													#  at the second record
	
	my $statRep = sprintf ("%d %10.2f %10.2f %10.2f %10.2f %10.2f\n", 
		$totPur, $totLitGas, $totCoGas, $avCoLit, $avPurCo, $avFuelEff);
	
	if ($currency eq 'EU') {
     	 $statRep =~ s/\./,/g;
    }	
	print "$statRep";
}

print "\n\n";

close CSVFH or die "An error occured while trying to close the file: $fileName $!";

exit (0);