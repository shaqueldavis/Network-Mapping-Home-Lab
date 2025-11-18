Title: 
Network-Mapping

Brief Description: 
creating and maintaining a network baseline in a Linux environment.

Full Description:
Built and maintain a home lab for network asset management, performing host discovery with nmap -sn, establishing a baseline inventory of authorized devices with IP mappings and behavioral notes, protecting inventory integrity by generating SHA-256 hashes (sha256sum) and storing a signed, ASCII-armored encrypted copy with GPG (--local-user, --encrypt, --sign, --armor, -r), and running scheduled scans to detect and investigate unexpected or missing hosts.


PHASE 1: 
Establish a base line

Step 1.1: 
Create a dedicated folder for network mapping documents. Inside this folder create a document which contains a list of all known devices on your network. This document will serve as your baseline. It may consist of the following: 
Smart TV (Sony), laptop (google notebook), ipad (kid’s), ipad (wife’s), ipad (personal), iphone (personal), iphone (wife’s), desktop computer (HP)
Reference image 1.1

Step 1.2: 
Discover the local gate way. Use the <route -n> command to list your local gate way this provides you with the IP address of your router. In addition it reveals your subnet range. 
COMMAND: 
route -n

Step 1.3.1: 
Scan for live hosts on your network. Use the nmap tool combined with the host discovery scan parameter <-sn> on your subnet range. Run this command once in the morning. Once in the afternoon and once in the evening everyday for one week. In a home network most devices will only be live at certain times but not always. Seeing which host is up and when will give you a better understanding of what IP address correlates with which device on your base line list. As it is made clear, modify your baseline document and add IP addresses to match each host.
COMMAND:
nmap -sn 203.0.113.0/24
(replace 203.0.113.0/24 with your subnet range. Prepending sudo to the command, if you have permission. it will give a more thorough scan, e.g. revealing the host computer IP address if you are scanning on a VM.)

Step 1.3.2: 
If desired you can automate this process with the combination of a script and the cron service. See 1.3.2-nmap-host-scan-script and 1.3.2-Crontab-schedule in the scripts folder.
You will need to edit 3 things in the script and 2 things in the cron entries. So 5 edits total.
First: the Nmap path. Make sure the nmap path in the script matches the path on your machine. Run the following command to discover the path.
COMMAND:
Which nmap
Second: Set the path to the OUTDIR variable (output directory) to your choice. This directory will be populated with grapable nmap files for each scan conducted by the script.
Third: the START_DATE variable will need to be changed to your start date of choice. The date should be in YYYY-MM-DD format. The script will run for your start date and an additional 6 days (one week total). 
Fourth: in the cron text to the left of the append redirect (>>) is the path pointing to where you have the script saved on your machine. You will have to edit it accordingly. 
Fifth: the cron tab text to the right of the append redirect is the path pointing to where you want the crontab logs to be stored. 
Note: whichever machine you are using to perform the automated scan will need to be powered on and connected to your local network throughout the entirety of the scan process for the best results.

Step 1.4:
Update your baseline in consideration of the information found in the individual nmap scans, which will also be available collectively in the cron.log file. You can optionally play around with turning devices on and off, manually running the following command and looking at which IP addresses correlate with each of your devices. Any IP addresses in the scan documents or log file that do not match any of your devices should be flagged for further investigation.


PHASE 2:
Securing your baseline’s integrity

Step 2.1:
Now that you have a baseline document you want to make sure that you can detect if this baseline is ever altered to include any rogue IP addresses. Get a hash of your document by performing the following 
COMMAND:
sha256sum baseline-document
(replace “baseline-document” with the name of your baseline document)
Copy the hash of your baseline and place it into a new file.
Command:
Echo “your hash here” > hash-of-baseline
Then place the file containing your baseline hash as well as a copy of your baseline document and place them into a new directory.
COMMAND:
Mkdir baseline-integrity

Step 2.2:
Encrypt the baseline file and the file containing the hash of the baseline file for an additional layer of protection. This way if anyone was to modify the baseline document you can compare a current hash to the hash we just created as well as have a visual comparison of the encrypted backup baseline file.
COMMAND:
Gpg --local-user your-local-user --encrypt --sign --armor -r --your-local-user hash-of-baseline-file.txt
(run the command again specifying the copy of your baseline file)
Gpg --local-user your-local-user --encrypt --sign --armor -r --your-local-user copy-of-baseline.txt


PHASE 3:
Regular scanning

Step 3.1: 
Run a reconfiguration of the nmap script from earlier. This version is exactly the same with one exception, there is no specified date. As a result the script will run anytime cron instructs it to do so. In other words it will run continuously. See 3.1-nmap-host-scan-script.
The simplest implementation of this script is to replace your original nmap script with this one or change the date section in your current script under “--- CONFIG ---”  to match the new script. If you chose either option you will not need to modify the cron file. If you add this script as a secondary file you will need to update the cron file entries to point to this new script.
Note: continuously running this script will lead to a consistently growing cron log file and nmap output files in your specified output directory. You will need to watch this directory to purge when needed. 

Step 3.2:
Compare scans to baseline by utilizing a script that extracts IP addresses from the log file or an individual .gnmap scan file and compares them to IP addresses present in your baseline file. The script determines which addresses are present in a scan but not in your baseline, present in your baseline but not in your scan, and a collective of all live hosts in your scan. See 3.2 compare-script.sh
COMMAND:
Compare-script.sh baseline.txt cron.log




