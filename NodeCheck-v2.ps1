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

#processing Nodes info
$Nodeinfo = Import-CSV ".\$IPList" | ForEach {./nknc --ip $_.ip info -s} 
Write-Host "Nodes info processed.." -ForegroundColor White -BackgroundColor Blue

#processing ip addresses 
$Address =  $Address + $Nodeinfo | sls addr
$i=0;for ($i=0; $i -le $Address.Length-1; $i++) {$Address[$i] = $Address[$i] -replace ".*/"; $Address[$i] = $Address[$i].Substring(0, $Address[$i].IndexOf(':'))}
Write-Host "IP addresses processed.." -ForegroundColor White -BackgroundColor Blue


#processing public key
$Publickey = $Publickey +$Nodeinfo | sls publickey
$i=0;for ($i=0; $i -le $Publickey.Length-1; $i++) {$Publickey[$i] = $Publickey[$i] -replace ".*:" ;$Publickey[$i] = $Publickey[$i].Trim(","," ")}
Write-Host "Publickey processed.." -ForegroundColor White -BackgroundColor Blue

#processing blocks proposed
$BlocksList =  $BlocksList + $Nodeinfo | sls proposalSubmitted
$i=0;for ($i=0; $i -le $BlocksList.Length-1; $i++) {$BlocksList[$i] = $BlocksList[$i] -replace ".*:" ; $BlocksList[$i] = $BlocksList[$i].Trim(","," ")}
Write-Host "Blocks Proposed processed.." -ForegroundColor White -BackgroundColor Blue

#processing # connections
$ConnectionsList = Import-CSV ".\$IPList" | ForEach {./nknc --ip $_.ip info --connections} | sls result
$i=0;for ($i=0; $i -le $ConnectionsList.Length-1; $i++) {$ConnectionsList[$i] = $ConnectionsList[$i] -replace ".*:"}
Write-Host "# Connections processed.." -ForegroundColor White -BackgroundColor Blue

#processing node state 
$StateList = $StateList +$Nodeinfo | sls SyncState
$i=0;for ($i=0; $i -le $StateList.Length-1; $i++) {$StateList[$i] = $StateList[$i] -replace ".*:" ;$StateList[$i] = $StateList[$i].Trim(","," ")}
Write-Host "Node State processed.." -ForegroundColor White -BackgroundColor Blue

#processing relayed messages 
$RelayedList = $RelayedList + $Nodeinfo | sls relayMessageCount
$i=0;for ($i=0; $i -le $RelayedList.Length-1; $i++) {$RelayedList[$i] = $RelayedList[$i] -replace ".*:" ;$RelayedList[$i] = $RelayedList[$i].Trim(","," ")}
Write-Host "Relayed Messages processed.." -ForegroundColor White -BackgroundColor Blue

#processing total uptime
$UptimeList = $UptimeList + $Nodeinfo | sls uptime
$i=0;for ($i=0; $i -le $UptimeList.Length-1; $i++) {$UptimeList[$i] = $UptimeList[$i] -replace ".*:" ;$UptimeList[$i] = $UptimeList[$i].Trim(","," ")}
Write-Host "Uptime processed.." -ForegroundColor White -BackgroundColor Blue

#processing version
$Version = $Version + $Nodeinfo | sls version -CaseSensitive
$i=0;for ($i=0; $i -le $Version.Length-1; $i++) {$Version[$i] = $Version[$i] -replace ".*:";$Version[$i] = $Version[$i].Trim(","," ")}
Write-Host "Version processed.." -ForegroundColor White -BackgroundColor Blue

#processing block height 
$Height = $Height + $Nodeinfo | sls height
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


$CSV = Import-CSV ".\$IPList"

#add the Region column 
if ($Region -ne "") {$CSV | Add-Member -MemberType NoteProperty "Region" -Value $Region}

#add new columns
$CSV | Add-Member -MemberType NoteProperty "IPaddress" -Value ""
$CSV | Add-Member -MemberType NoteProperty "Publickey" -Value ""
$CSV | Add-Member -MemberType NoteProperty "BlocksProposed" -Value "" 
$CSV | Add-Member -MemberType NoteProperty "Connections" -Value ""
$CSV | Add-Member -MemberType NoteProperty "State" -Value ""
$CSV | Add-Member -MemberType NoteProperty "RelayedMessages" -Value ""
$CSV | Add-Member -MemberType NoteProperty "RelayedperHour" -Value ""
$CSV | Add-Member -MemberType NoteProperty "UptimeDays" -Value ""
$CSV | Add-Member -MemberType NoteProperty "Version" -Value ""
$CSV | Add-Member -MemberType NoteProperty "Height" -Value ""

#fill columns with data
$i=0;for ($i=0; $i -le $CSV.Length-1; $i++) {$CSV[$i].IPaddress = $Address[$i];$CSV[$i].Publickey = $Publickey[$i];$CSV[$i].BlocksProposed = $BlocksList[$i];$CSV[$i].Connections = $ConnectionsList[$i];$CSV[$i].State = $StateList[$i];$CSV[$i].RelayedMessages = $TotalRelayed[$i];$CSV[$i].RelayedperHour = $RelayedHour[$i];$CSV[$i].UptimeDays = $TotalUptime[$i];$CSV[$i].Version = $Version[$i];$CSV[$i].Height = $Height[$i]}

#clear ip column in case there was a node with no connection and the array misplaces rows
$i=0;for ($i=0; $i -le $CSV.Length-1; $i++) {$CSV[$i].ip = " "}


#create the Powershell Table
if ($CSV.Region[0]) {$Region = "1"}

if (-not $Region) {$CSV | Select-Object -Property IPaddress, Publickey, BlocksProposed, Connections, State, RelayedMessages, RelayedperHour, UptimeDays, Version, Height | Out-GridView -Title  "Check Nodes"}
                  else {$CSV | Select-Object -Property IPaddress, Region, Publickey, BlocksProposed, Connections, State, RelayedMessages, RelayedperHour, UptimeDays, Version, Height | Out-GridView -Title  "Check Nodes"}

#getting date to add to csv filename
$date = (get-date).tostring("d.M.yyyy hhmm tt")

#exporting CSV file
if (-not $Region) {$CSV | Select-Object -Property IPaddress, Publickey, BlocksProposed, Connections, State, RelayedMessages, RelayedperHour, UptimeDays, Version, Height | Export-Csv -Path ".\Check-Nodes $date.csv" -NoTypeInformation}
                  else 
                  {$CSV | Select-Object -Property IPaddress, Region, Publickey, BlocksProposed, Connections, State, RelayedMessages, RelayedperHour, UptimeDays, Version, Height | Export-Csv -Path ".\Check-Nodes $date.csv" -NoTypeInformation}

Write-Host "Check-Nodes $date.csv has been created. You can open it on MS EXCEL" -ForegroundColor White -BackgroundColor Red
Write-Host "NOTE: Blocks Proposed counter (Rewarded & Refused) restarts if Node does" -ForegroundColor yellow -BackgroundColor Red
Write-Host "NOTE: Current Version gets the Version of your local Windows NKN" -ForegroundColor yellow -BackgroundColor Red

$lasthash = .\nknc.exe --ip $Address[0] info --latestblockhash | sls hash
$lastheight = .\nknc.exe --ip $Address[0] info --latestblockhash | sls height

$CurrentVersion = .\nknc.exe -v
$CurrentVer = "Current"
$CurrentVer = "Current " + $CurrentVersion
Write-Host "$CurrentVer" -ForegroundColor White -BackgroundColor Green
Write-Host "Latest Block" -ForegroundColor White -BackgroundColor Green
Write-Host "$lasthash" -ForegroundColor White -BackgroundColor Green
Write-Host "$lastheight" -ForegroundColor White -BackgroundColor Green
pause




