Param(
    [switch]$Install,
    [string]$WorkingDirectory = "./"
)

#
# Connect to sheets and retrieve file, store as ./sheet.tmp.json
# parse sheet.tmp.json and retrieve UUID
# create whitelist.json based on info

#https://developers.google.com/drive/api/v3/quickstart/python

if ($Install.IsPresent -eq $true){
    #curl https:/bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py #assume you already have pip
    #chmod +x ./get-pip.py
    #/usr/bin/python3.8 get-pip.py
    python3 -m venv virtenv
    pip install -r requirements.txt
    ./virtenv/Scripts/activate.ps1
    "Edit sync.settings.cfg and get service acc json" | write-host -ForegroundColor magenta
    start-sleep -Seconds 5
    exit 0
}

function Get-MCData(){
Param(
    [string]$username
)
    $uri = $API_URL+"/"+$username
    $result = Invoke-RestMethod -Uri $uri -Method get
    return $result
}

Function Get-WList() {
    $List = Get-Content -Path .\sheet.tmp.json -raw | convertfrom-json | where {$_.username -ne ""} | select @{n="name";e={$_.username}},@{n="Goedgekeurd";e={$_.Goedgekeurd -eq "TRUE"}}
    foreach($u in $List) {
        $u | add-member -MemberType NoteProperty -Name uuid -Value $(Get-MCData -username $u.name ).ID -force
    }
    return $list.where({$_.goedgekeurd -eq $true -and $_.uuid -ne $null})  | select uuid,name
}

& ./virtenv/Scripts/activate.ps1
New-Variable -Name API_URL -Value  "https://api.mojang.com/users/profiles/minecraft" -Option ReadOnly -force
$filepath = join-path "$WorkingDirectory" "whitelist.json"
copy-item -path "$filepath" -Destination "./whitelist.json.$(get-date -Format 'yyyyMMdd_HHmmss').bak"
Python ./sync.py
$whitelist = Get-WList
$whitelist | convertto-json | out-file -FilePath $filepath