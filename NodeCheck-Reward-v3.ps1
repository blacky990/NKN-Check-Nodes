#NodeCheck v1.0 for NKN network (nkn.org) created by blacky990 (July 2019)
#IPList.csv need to have "ip" on the first row and ip addresses on each row

#cleaning variables for debugging
if ($CSV) {Remove-Variable CSV}
if ($Address) {Remove-Variable Address}

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
$i=0;for ($i=0; $i -le $Publickey.Length-1; $i++) {$Publickey[$i] = $Publickey[$i] -replace ".*:" ;$Publickey[$i] = $Publickey[$i].Trim(","," ");$Publickey[$i] = $Publickey[$i].Trim(","," ") -replace '"',''}
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
$i=0;for ($i=0; $i -le $StateList.Length-1; $i++) {$StateList[$i] = $StateList[$i] -replace ".*:" ;$StateList[$i] = $StateList[$i].Trim(","," ");$StateList[$i] = $StateList[$i].Trim(","," ") -replace '"',''}
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
$i=0;for ($i=0; $i -le $Version.Length-1; $i++) {$Version[$i] = $Version[$i] -replace ".*:";$Version[$i] = $Version[$i].Trim(","," ");$Version[$i] = $Version[$i].Trim(","," ") -replace '"',''}
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
if ($Region) {$CSV | Add-Member -MemberType NoteProperty "Region" -Value $Region}

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

#new feature - adding information about NKN mined and Blocks per node 
Write-Host "Input Beneficiary Wallet associated with IP List provided in order to check Rewards per node" -ForegroundColor blue -BackgroundColor yellow
$wallet = Read-Host -Prompt 'NKN Wallet Address (Enter for none)'


if ($wallet){

$balanced = .\nknc --ip $Address[0] info --balance $wallet | sls amount
$balanced = $balanced -replace ".*:"
$balanced = $balanced -replace '"',''
$balance = $balanced.substring(0, $balanced.IndexOf('.'))


$NumberofPages = [int]($balanced/11.41552511/10)

$BlocksMined = [int]($balanced/11.41552511)
$Pause = [int]($NumberofPages*5)

#cleaning variables
if ($Signer) {Remove-Variable Signer}
if ($Report) {Remove-Variable Report}
if ($BlocksRewarded) {Remove-Variable BlocksRewarded}
if ($BlocksHeight) {Remove-Variable BlocksHeight}
if ($BlocksQuery) {Remove-Variable BlocksQuery}

#Querying nknx api to get just Block Heights
Write-Host "Querying nknx api to get Block Heights mined with Wallet provided. Processing #$NumberofPages pages with a pause of 5 sec in between. $Pause sec estimated" -ForegroundColor yellow -BackgroundColor blue
Write-Host "If you see wget : The remote server returned an error: (429) Too Many Requests. means that nknx is saturated and we won't get the complete list of blocks mined" -ForegroundColor yellow -BackgroundColor red

function Get-Blocks {

                    $i=1;for ($i=1; $i -le $Numberofpages; $i++) {
                                        $transaction = wget https://api2.nknx.org/addresses/$wallet/transactions?page=$i
                                        $Contentnonce = @()
                                        $Contentnonce = $Contentnonce + $transaction | Select-Object -Property Content
                                        $Contentsmall = $Contentnonce -split "," | sls nonce
                                        $NewContentSmall = $Contentsmall.Line
                                        $j=0;for ($j=0; $j -le $NewContentSmall.Length-1; $j++) {$NewContentSmall[$j] = $NewContentSmall[$j] -replace ".*:";$NewContentSmall[$j] = $NewContentSmall[$j] -replace '"','' -replace '(^\s+|\s+$)','' -replace '\s+',' '}
                                        $BlocksHeight += $NewContentsmall
                                        Write-Host "Page #$i processed. Waiting 5 sec to not saturate nknx api..." -ForegroundColor white -BackgroundColor Red
                                        Start-Sleep -Seconds 5
                                        }

                                $BlocksHeight = $BlocksHeight | Select -Unique
                                Write-Host "Did you get errors? Would you like to repeat the query?" -ForegroundColor yellow -BackgroundColor Red
                                $Query = Read-Host -Prompt "Yes/No (y/n)"
                                if (($Query -eq 'y') -or ($Query -eq 'Yes') -or ($Query -eq 'yes') -or ($Query -eq 'Y') -or ($Query -eq 'YES')) {Get-Blocks}
                    
                    Return $BlocksHeight
                    }
$BlocksQuery = Get-Blocks

$Blocks = $BlocksQuery | Select-Object @{Name='Blocks';Expression={$_}}
$Blocks | Export-Csv .\ExportBlocks.csv -NoType

$BlocksRewarded = Import-CSV ".\ExportBlocks.csv" 

$Signer = @()
$Signer += $BlocksRewarded
#removing spaces in string (if necesary)
$i=0;for ($i=0; $i -le $Signer.Length-1; $i++) {$Signer[$i].Blocks = $Signer[$i].Blocks -replace '(^\s+|\s+$)','' -replace '\s+',' '}

#adding column SignerPk
if (-not $Signer.SignerPk[0]) {$Signer | Add-Member -MemberType NoteProperty "SignerPk" -Value "0"}

#querying SignerPk using nknc.exe
Write-Host "querying SignerPk using nknc.exe..." -ForegroundColor white -BackgroundColor Red
$i=0;for ($i=0; $i -le $Signer.Length-1; $i++) {$Signer[$i].SignerPk = .\nknc.exe --ip $address[0] info --height $Signer[$i].Blocks | sls signerPk}
#cleaning the string Signer
$i=0;for ($i=0; $i -le $Signer.Length-1; $i++) {$Signer[$i].SignerPk = $Signer[$i].SignerPk -replace ".*:" ;$Signer[$i].SignerPk = $Signer[$i].SignerPk.Trim(","," ");$Signer[$i].SignerPk = $Signer[$i].SignerPk -replace '"',''}

$Signer | Select-Object -Property Blocks, SignerPk |  Export-Csv .\ExportSignerPk.csv -NoType

$Report += $CSV 
#adding Rewards column with temporary 0 value (in case you're lucky this will change)
$Report | Add-Member -MemberType NoteProperty "Rewards" -Value "0"


$i=0;for ($i=0; $i -le $Signer.Length-1; $i++) { $match = $Signer[$i].SignerPk
                                                $j=0;
                                                for ($j=0; $j -le $Report.Length-1; $j++){
                                                if ($Report[$j].Publickey -eq $match) {$Report[$j].Rewards = [int]($Report[$j].Rewards)+1}
                                                }
                                                }
                                                
                                              

$Report | Out-GridView -Title  "NKN Nodes Report"

#getting date to add to csv filename
$date = (get-date).tostring("d.M.yyyy hhmm tt")

#exporting Report CSV file
if (-not $Region) {$Report | Select-Object -Property IPaddress, Publickey, BlocksProposed, Connections, State, RelayedMessages, RelayedperHour, UptimeDays, Version, Height, Rewards | Export-Csv -Path ".\Report-Nodes $date.csv" -NoTypeInformation}
                  else 
                  {$Report | Select-Object -Property IPaddress, Region, Publickey, BlocksProposed, Connections, State, RelayedMessages, RelayedperHour, UptimeDays, Version, Height, Rewards | Export-Csv -Path ".\Report-Nodes $date.csv" -NoTypeInformation}

Write-Host "Beneficiary NKN Wallet = $wallet" -ForegroundColor Blue -BackgroundColor Yellow
Write-Host "Balance = $Balanced NKN" -ForegroundColor Blue -BackgroundColor Yellow
Write-Host "Blocks Rewarded = $BlocksMined" -ForegroundColor Blue -BackgroundColor Yellow
pause
}
else{pause}



