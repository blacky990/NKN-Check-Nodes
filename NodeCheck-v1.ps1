#NodeCheck v1.0 for NKN network (nkn.org) created by blacky990 (July 2019)
#IPList.csv need to have "ip" on the first row and ip addresses on each row

#read csv file & input Region

$IPList = "IPList.csv"

Write-Host "IPList.csv need to have "ip" on the first row and ip addresses on each row" -ForegroundColor yellow -BackgroundColor Red
$IPList= Read-Host -Prompt 'Input the IP List csv filename (default=IPList.csv)' 
if ($IPList -eq "") {$IPList = "IPList.csv"}
if (-not $IPList.EndsWith(".csv")) {$IPList = $IPList + ".csv"}

$Region= Read-Host -Prompt 'Region of the IP List (Enter for none)' 
Write-Host "Processing data...Messages below show IP's with no connection." -ForegroundColor White -BackgroundColor Red

#processing blocks proposed
$BlocksList = Import-CSV ".\$IPList" | ForEach {./nknc --ip $_.ip info -s} | sls proposalSubmitted
$i=0;for ($i=0; $i -le $BlocksList.Length-1; $i++) {$BlocksList[$i] = $BlocksList[$i] -replace ".*:" ; $BlocksList[$i] = $BlocksList[$i].Trim(","," ")}
Write-Host "Blocks Proposed processed.." -ForegroundColor White -BackgroundColor Blue

#processing # connections
$ConnectionsList = Import-CSV ".\$IPList" | ForEach {./nknc --ip $_.ip info --connections} | sls result
$i=0;for ($i=0; $i -le $ConnectionsList.Length-1; $i++) {$ConnectionsList[$i] = $ConnectionsList[$i] -replace ".*:"}
Write-Host "# Connections processed.." -ForegroundColor White -BackgroundColor Blue

#processing node state 
$StateList = Import-CSV ".\$IPList" | ForEach {./nknc --ip $_.ip info -s} | sls SyncState
$i=0;for ($i=0; $i -le $StateList.Length-1; $i++) {$StateList[$i] = $StateList[$i] -replace ".*:" ;$StateList[$i] = $StateList[$i].Trim(","," ")}
Write-Host "Node State processed.." -ForegroundColor White -BackgroundColor Blue

#processing relayed messages 
$RelayedList = Import-CSV ".\$IPList" | ForEach {./nknc --ip $_.ip info -s} | sls relayMessageCount
$i=0;for ($i=0; $i -le $RelayedList.Length-1; $i++) {$RelayedList[$i] = $RelayedList[$i] -replace ".*:" ;$RelayedList[$i] = $RelayedList[$i].Trim(","," ")}
Write-Host "Relayed Messages processed.." -ForegroundColor White -BackgroundColor Blue

#processing total uptime
$UptimeList = Import-CSV ".\$IPList" | ForEach {./nknc --ip $_.ip info -s} | sls uptime
$i=0;for ($i=0; $i -le $UptimeList.Length-1; $i++) {$UptimeList[$i] = $UptimeList[$i] -replace ".*:" ;$UptimeList[$i] = $UptimeList[$i].Trim(","," ")}
Write-Host "Uptime processed.." -ForegroundColor White -BackgroundColor Blue

#processing version
$Version = Import-CSV ".\$IPList" | ForEach {./nknc --ip $_.ip info -s} | sls version -CaseSensitive
$i=0;for ($i=0; $i -le $Version.Length-1; $i++) {$Version[$i] = $Version[$i] -replace ".*:";$Version[$i] = $Version[$i].Trim(","," ")}
Write-Host "Version processed.." -ForegroundColor White -BackgroundColor Blue

#processing block height 
$Height = Import-CSV ".\$IPList" | ForEach {./nknc --ip $_.ip info -s} | sls height
$i=0;for ($i=0; $i -le $Height.Length-1; $i++) {$Height[$i] = $Height[$i] -replace ".*:" ;$Height[$i] = $Height[$i].Trim(","," ")}
Write-Host "Block Height processed.." -ForegroundColor White -BackgroundColor Blue

#to pass $UptimeList & $RelayedList to integer in order to divide them
$i=0;for ($i=0; $i -le $RelayedList.Length-1; $i++) {$RelayedList[$i] = [int]$RelayedList[$i]}
$i=0;for ($i=0; $i -le $UptimeList.Length-1; $i++) {$UptimeList[$i] = [int]$UptimeList[$i]}

$TotalRelayed = @()
$TotalRelayed = $TotalRelayed + $RelayedList

$RelayedHour = $RelayedList
$i=0;for ($i=0; $i -le $RelayedHour.Length-1; $i++) {$RelayedHour[$i] = [int]($RelayedList[$i]*3600/$UptimeList[$i])}

$TotalUptime = $UptimeList
$i=0;for ($i=0; $i -le $TotalUptime.Length-1; $i++) {$TotalUptime[$i] = [int]($UptimeList[$i]/86400)}

$IPprocessed = $BlocksList.Count

Write-Host "Data has been generated. $IPprocessed IP's processed" -ForegroundColor White -BackgroundColor Red

#import csv file
$CSV = Import-CSV ".\$IPList"

#add the Region column 
if ($Region -ne "") {$CSV | Add-Member -MemberType NoteProperty "Region" -Value $Region}

#add new columns
$CSV | Add-Member -MemberType NoteProperty "BlocksProposed" -Value "" 
$CSV | Add-Member -MemberType NoteProperty "Connections" -Value ""
$CSV | Add-Member -MemberType NoteProperty "State" -Value ""
$CSV | Add-Member -MemberType NoteProperty "RelayedMessages" -Value ""
$CSV | Add-Member -MemberType NoteProperty "RelayedperHour" -Value ""
$CSV | Add-Member -MemberType NoteProperty "UptimeDays" -Value ""
$CSV | Add-Member -MemberType NoteProperty "Version" -Value ""
$CSV | Add-Member -MemberType NoteProperty "Height" -Value ""

#fill columns with data
$i=0;for ($i=0; $i -le $CSV.Length-1; $i++) {$CSV[$i].BlocksProposed = $BlocksList[$i];$CSV[$i].Connections = $ConnectionsList[$i];$CSV[$i].State = $StateList[$i];$CSV[$i].RelayedMessages = $TotalRelayed[$i];$CSV[$i].RelayedperHour = $RelayedHour[$i];$CSV[$i].UptimeDays = $TotalUptime[$i];$CSV[$i].Version = $Version[$i];$CSV[$i].Height = $Height[$i]}

#create the Powershell Table
$CSV | Out-GridView -Title  "Check Nodes"

$date = (get-date).tostring("d.M.yyyy hhmm tt")

$CSV | Export-Csv -Path ".\Check-Nodes $date.csv" -NoTypeInformation

Write-Host "Check-Nodes $date.csv has been created. You can open it on MS EXCEL" -ForegroundColor White -BackgroundColor Red
Write-Host "NOTE: Blocks Proposed counter (Rewarded & Refused) restarts if Node does" -ForegroundColor yellow -BackgroundColor Red
Write-Host "NOTE: Current Version gets the Version of your local Windows NKN" -ForegroundColor yellow -BackgroundColor Red

$lasthash = .\nknc.exe --ip $CSV.ip[0] info --latestblockhash | sls hash
$lastheight = .\nknc.exe --ip $CSV.ip[0] info --latestblockhash | sls height

$CurrentVersion = .\nknc.exe -v
$CurrentVer = "Current"
$CurrentVer = "Current " + $CurrentVersion
Write-Host "$CurrentVer" -ForegroundColor White -BackgroundColor Green
Write-Host "Latest Block" -ForegroundColor White -BackgroundColor Green
Write-Host "$lasthash" -ForegroundColor White -BackgroundColor Green
Write-Host "$lastheight" -ForegroundColor White -BackgroundColor Green
pause




