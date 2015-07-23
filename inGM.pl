#!/usr/bin/perl
#**************************************************************************************************************
#
#	File Name: inGM.pl
#
#	Author: Matthew Cibulka (0664008)
#
#	Date Created: Wednesday, February 16, 2011
#	Last Updated: Friday, February 18, 2011  
#     
#	Summary:
#		This is the input program for the Green Machine project.  It allows the user to add additional 
#		records to a specified CSV file.  If the specified file is not found, a new CSV file will be created 
#		to store the data.
#
#	Command Line Parameters:
#   	$ARGV[0] = name of the file that will be opened or created to store the car information
#	 	$ARGV[1] = type of currency and real number format used 
#	    	- 'NA' for North America (dollars and period)
#	     	- 'EU' for European Union (euros and comma)		
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

#  Input
my $dateIn = '';
my $timeIn = '';
my $currOdomIn = 0;
my $litGasPurIn = 0;
my $coLitGasIn = 0;
my $newRecLoop = -1;

#  Calculations
my $purCost = 0;
my $purCostStr = '';

#  Write CSV File
my $newRecord;


open (CSVFH, ">>$fileName") or die "An error has occurred, $fileName was unable to open.\n$!";	
	      #  '>>' specifies to write or append to an existing file, or create a new file

print "\n\nGreen Machine Input\n";
print "===================\n\n";


#  '-z' is a file test to check if the file is empty, if true, assumption is that a new file has just been created
if (-z CSVFH)		
{	
	print "The file name specified, \"$fileName\" was not found.\n";
	print "It has been created for you.\n";
	
	#  field titles need to be added as the first line 	
	if ($currency eq 'NA') {
		print CSVFH "\"Date\",\"Time\",\"Odometer\",\"Litres of Gas\",\"Cost Per Litre\",\"Payment\"\n";	
	}
	elsif ($currency eq 'EU') {
		print CSVFH "\"Date\";\"Time\";\"Odometer\";\"Litres of Gas\";\"Cost Per Litre\";\"Payment\"\n";	
	}
}
else {	#  file exists
	print "\"$fileName\" has been found, any new records inputted below will be added to it.\n";
}

do
{
	my $validInFl = -1;	#  flag for valid input
	
	print "\nPlease enter the following data.";
	print "\n\nDate of Purchase (MM/DD/YYYY): ";
	$dateIn = <STDIN>;
	chomp ($dateIn);	#  remove '\n' from end of input

	print "Time of Purchase (HH:MM): ";
	$timeIn = <STDIN>;
	chomp ($timeIn);

	print "Current Odometer Reading: ";
	$currOdomIn = <STDIN>;
	chomp ($currOdomIn);

	my $verifyPPLoop = 0;		#  PP = Purchase Price
	my $verifyCount = -1;		#  -1 to allow field titles to pass
	
	do 	#  loop until purchase price has been verified
	{	
		$verifyCount++;
		
		if ($verifyCount >= 1) {
			print "\nPlease enter the following data again.\n\n";
		}
		
		print "Number of Litres of Gas Purchased: ";
		$litGasPurIn = <STDIN>;
		chomp ($litGasPurIn);

		print "Cost per Litre of Gas: ";
		$coLitGasIn = <STDIN>;
		chomp ($coLitGasIn);
		
		if ($currency eq 'EU') {	#  substitute the comma for a decimal in order to calculate purchase cost	
			$litGasPurIn =~ s/,/./;
			$coLitGasIn =~ s/,/./;
		}

		$purCost = $litGasPurIn * $coLitGasIn;
		$purCostStr = sprintf ("\nThe purchase price has been calculated for you: %.2f\n", $purCost);

		if ($currency eq 'EU') {	#  swap period back to comma
			$purCostStr =~ s/\./,/;
		}

		print "$purCostStr";
		do
		{
			my $loopIn = '';
			
			print "\nPlease verify that this correct (y/n): ";
			$loopIn = <STDIN>;
			chomp ($loopIn);
	
			if (lc($loopIn) eq 'y') {	#  'lc ()' changes string to lowercase letters, correct, add record, 
				$verifyPPLoop = 1;
				$validInFl = 1;
			}
			elsif (lc($loopIn) eq 'n') {	#  assume error in entry of data, try again
				$verifyPPLoop = 0;
				$validInFl = 1;
			}
			else {		#  invalid input
				print "\nOops! Invalid input.\n";
				$validInFl = 0;
			}		
		} until ($validInFl == 1);
		
	} until ($verifyPPLoop == 1); 


	#  concatenate into one string to write to file
	if ($currency eq 'NA') {
		$newRecord = sprintf ("$dateIn,$timeIn,$currOdomIn,%.3f,%.3f,%.2f", $litGasPurIn, $coLitGasIn, $purCost);
	}
	elsif ($currency eq 'EU') {
		$newRecord = sprintf ("$dateIn;$timeIn;$currOdomIn;%.3f;%.3f;%.2f", $litGasPurIn, $coLitGasIn, $purCost);
		$newRecord =~ s/\./,/g;		#  '\' needed before '.' because it is a metacharacter 									
	}								#  'g' (global) flag signals to substitute every occurance in string

	print CSVFH "$newRecord\n";		#  add new record to file
	print "Thank you, your file has been updated.\n";	
	
	
	do 	#  loop until the user enters valid data
	{	
		my $loopIn = '';
		
		print "\nWould you like to enter another record? (y/n): ";
		$loopIn = <STDIN>;
		chomp ($loopIn);
	
		if (lc($loopIn) eq 'y')		#  add a new record, 'lc ()' changes string to lowercase letters 
		{	
			$newRecLoop = 1;
			$validInFl = 1;
			$verifyCount = 0;
		}
		elsif (lc($loopIn) eq 'n') {	#  exit program
			$newRecLoop = 0;
			$validInFl = 1;
		}
		else {		#  invalid input
			print "\nOops! Invalid input.\n";
			$validInFl = 0;
		}	
	} until ($validInFl == 1);
	
} while ($newRecLoop == 1);

print "\n\nAll records inputted during this session can be found in the following file, \"$fileName\".";
print "\nHave a nice day!\n\n";

close (CSVFH) or die "An error occured while trying to close the file: $fileName $!";

exit (0);
