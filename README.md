# Green Machine
## Overview
The Green Machine project is a set of programs that allows a user to track and view gas milage for a vehicle. There is an input program and output program.  The input program prompts the user to enter data in a friendly and easy way.  The output program displays informative data in an organized manner.  The programs account for two different sets of data:

1. North American (NA), with a period separator
2. European Union (EU), with a comma separator

### inGM
inGM is the input program.  It allows the user to add additional records to an existing CSV file or begin record keeping by creating a new CSV file.  If the specified file is not found, a new CSV file will be created to store the data.
### outGM
This is the output program.  It will read the specified CSV file and dispay either a Statistical or Full report of the data.  A Full report will print out all records, plus calculated data pertaining to each record.  A Statistical report will display a summmary of all the records in a single line.  The format of the output is outlined below.
#### Full
The following will be displayed for each record, on a single line and in this order:
- MM/DD/YYYY
- HH:MM
- Odometer (KM)
- Litres of Gas
- Cost Per Litre
- Payment 
- Fuel Efficiency
- Cumulative Total of Gas    
- Cumulative Total Cost

#### Statistical
The following will be displayed on a single line and in this order:
- Total number of fuel purchased
- Total number of litres of gas purchased
- Total cost of fuel purchases
- Average cost per litre of gas
- Average number of litres per purchase
- Average fuel efficiency (L/100 KM)

## To Run
Note: requires [Text::CSV](http://search.cpan.org/perldoc?Text%3A%3ACSV)
<br>
<br>
Open Terminal and enter:
### inGM.pl
````
$ perl inGM.pl <CSV file> <'NA' or 'EU'>   

# e.g.
$ perl inGM.pl smallCSVFile2.csv NA
```
### outGM.pl
````
$ perl outGM.pl <CSV File> <'F' or 'S'>

# e.g.
$ perl outGM.pl <smallCSVFile2.csv> F
```
