# NKN-Check-Nodes
This is just an unofficial script on Powershell I have created in order to input a bunch of ip's and get at a glance the status provided by nknc.exe. The script also export a csv file with all the processed data so you can import it with Ms Excel and play with the data.

You need to have the latest NKN version on windows. Download windows-amd64.zip version for x64 architecture https://github.com/nknorg/nkn/releases

Download, change the extension of the 2 files in order to have "nknc.exe" & "nknd.exe"

You also need the file config.json on the same folder.
Download Source code (zip) where you got windows-amd64, extract it and get the file config.mainnet.json. After that, just rename config.mainnet.json to config.json and place it on the same folder where nknc.exe.

This is a beta version. In case the script detects an ip address with no connection, the script won't skip that cell on the array. Therefore the final data may not correspond with the ip address because has been misplaced on the wrong row. If anyone knows how to fix it, just let me know.

If all nodes have connection, the script gives the correct data.

Note: The file with the ip's (IPList.csv) need to have "ip" on the first row and ip addresses on each row. 
Blocks Proposed counter (Rewarded & Refused) restarts if Node does. 
Current Version gets the Version of your local Windows nknc.exe.

---

NodeCheck-v2.ps1
Version 2 Changelog:

Faster script. Now gets info -s just once.

Fixed when script found nodes with no connection and data was misplaced regarding to the ip.

Added Publickey Value in order to compare with Block Signer and see which node got the reward.


Enjoy!
