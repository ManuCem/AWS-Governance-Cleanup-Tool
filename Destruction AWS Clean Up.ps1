$ErrorActionPreference = "SilentlyContinue"
Clear-Host

# 1. SETUP DATA & LOGGING
$logContent = @()
$graveyard = [Ordered]@{ 
    S3 = @(); EC2 = @(); IAM = @(); Lambda = @(); RDS = @()
    Dynamo = @(); EBS = @(); Logs = @(); Glue = @() 
}

# --- AESTHETIC HEADER ---
Write-Host "`n=======================================================" -ForegroundColor Red
Write-Host "   ☢️   WELCOME TO DESTRUCTION: AWS CLEANUP   ☢️" -ForegroundColor Yellow
Write-Host "=======================================================" -ForegroundColor Red

# 2. THE MENU
Write-Host "`n[1]  S3 Buckets"
Write-Host "[2]  EC2 Instances"
Write-Host "[3]  IAM Roles"
Write-Host "[4]  Lambda Functions"
Write-Host "[5]  RDS Databases"
Write-Host "[6]  DynamoDB Tables"
Write-Host "[7]  EBS Volumes"
Write-Host "[8]  CloudWatch Logs"
Write-Host "[9]  GLUE (Crawlers, DBs, ETL)"
Write-Host "[10] THE NUCLEAR OPTION (ALL OF THE ABOVE) ☢️ ☢️ ☢️" -ForegroundColor Red

$selection = Read-Host "`n⚔️  Select targets (e.g., 1,2,9)"
$choices = $selection -split "," | ForEach-Object { $_.Trim() }

# 3. GLUE SUB-MENU LOGIC
# Default to "All" (4) if Nuclear is chosen, otherwise ask user.
$glueSubChoice = "4" 

if ($choices -contains "9" -and -not ($choices -contains "10")) {
    Write-Host "`n--- 🧪 GLUE SPECIFICS 🧪 ---" -ForegroundColor Yellow
    Write-Host "1. Crawlers"
    Write-Host "2. Data Catalog Databases"
    Write-Host "3. Visual ETL Jobs"
    Write-Host "4. DELETE ALL GLUE RESOURCES"
    $glueSubChoice = Read-Host "Select Glue Target (1-4)"
}

# 4. NUCLEAR WARNING LOGIC
if ($choices -contains "10") {
    Write-Host "`n" + ("!" * 50) -ForegroundColor Red
    Write-Host "⚠️  ARE YOU REALLY SURE?" -ForegroundColor White -BackgroundColor Red
    Write-Host "You are about to delete: S3, EC2, IAM, Lambda, RDS, Dynamo, EBS, Logs..." -ForegroundColor Red
    Write-Host "AND GLUE (Includes Visual ETL, Crawler, and Database in Data Catalog)!" -ForegroundColor Yellow
    Write-Host ("!" * 50) -ForegroundColor Red
    
    if ((Read-Host "`nType 'y' to confirm destruction") -ne "y") { Write-Host "❌ Aborted."; exit }
}

Write-Host "`n🔍 SEARCHING INFRASTRUCTURE..." -ForegroundColor Gray

# 5. DESTRUCTION LOOP
foreach ($c in $choices) {
    
    # --- S3 ---
    if ($c -eq "1" -or $c -eq "10") {
        $list = aws s3api list-buckets --query "Buckets[*].Name" --output text
        if ($list -and $list -ne "None") { ($list -split "\s+") | ForEach-Object { aws s3 rb "s3://$_" --force; $graveyard.S3 += $_ } }
    }

    # --- EC2 ---
    if ($c -eq "2" -or $c -eq "10") {
        $list = aws ec2 describe-instances --query "Reservations[*].Instances[*].InstanceId" --output text
        if ($list -and $list -ne "None") { $ids = $list -split "\s+"; aws ec2 terminate-instances --instance-ids $ids; $graveyard.EC2 += $ids }
    }

    # --- LAMBDA ---
    if ($c -eq "4" -or $c -eq "10") {
        $list = aws lambda list-functions --query "Functions[*].FunctionName" --output text
        if ($list -and $list -ne "None") { ($list -split "\s+") | ForEach-Object { aws lambda delete-function --function-name $_; $graveyard.Lambda += $_ } }
    }

    # --- CLOUDWATCH ---
    if ($c -eq "8" -or $c -eq "10") {
        $list = aws logs describe-log-groups --query "logGroups[*].logGroupName" --output text
        if ($list -and $list -ne "None") { ($list -split "\s+") | ForEach-Object { aws logs delete-log-group --log-group-name $_; $graveyard.Logs += $_ } }
    }

    # --- GLUE LOGIC ---
    if ($c -eq "9" -or $c -eq "10") {
        # 1. Crawlers
        if ($glueSubChoice -eq "1" -or $glueSubChoice -eq "4") {
            $list = aws glue get-crawlers --query "Crawlers[*].Name" --output text
            if ($list -and $list -ne "None") { ($list -split "\s+") | ForEach-Object { aws glue delete-crawler --name $_; $graveyard.Glue += "Crawler: $_" } }
        }
        # 2. Databases
        if ($glueSubChoice -eq "2" -or $glueSubChoice -eq "4") {
            $list = aws glue get-databases --query "DatabaseList[*].Name" --output text
            if ($list -and $list -ne "None") { ($list -split "\s+") | ForEach-Object { aws glue delete-database --name $_; $graveyard.Glue += "DB: $_" } }
        }
        # 3. ETL Jobs
        if ($glueSubChoice -eq "3" -or $glueSubChoice -eq "4") {
            $list = aws glue get-jobs --query "Jobs[*].Name" --output text
            if ($list -and $list -ne "None") { ($list -split "\s+") | ForEach-Object { aws glue delete-job --job-name $_; $graveyard.Glue += "Job: $_" } }
        }
    }
}

# 6. GRAVEYARD REPORT
$header = "`n" + ("=" * 30) + "`n🪦 THE GRAVEYARD REPORT 🪦`n" + ("=" * 30)
Write-Host $header -ForegroundColor White -BackgroundColor DarkGray
$logContent += $header

$totalCount = 0
foreach ($key in $graveyard.Keys) {
    if ($graveyard[$key].Count -gt 0) {
        $sectionTitle = "`n⚰️ $key Service ($($graveyard[$key].Count) items):"
        Write-Host $sectionTitle -ForegroundColor Red -BackgroundColor Black
        $logContent += $sectionTitle
        
        foreach ($item in $graveyard[$key]) {
            Write-Host "   - $item" -ForegroundColor Red
            $logContent += "   - $item"
            $totalCount++
        }
    }
}

$footer = "`n🔥 TOTAL TERMINATED: $totalCount`n🏆 MISSION COMPLETE: AWS CLEANED"
Write-Host $footer -ForegroundColor Yellow
$logContent += $footer

# 7. SAVE FILE PROMPT
Write-Host "`n------------------------------------------"
$wantSave = Read-Host "💾 Do you want to save the Graveyard Log to a .txt file? (y/n)"

if ($wantSave -eq "y") {
    $fileName = "Graveyard_Log_$(Get-Date -Format 'yyyyMMdd_HHmm').txt"
    $logContent | Out-File -FilePath $fileName -Encoding UTF8
    Write-Host "✅ Log saved to: $fileName" -ForegroundColor Green
} else {
    Write-Host "❌ Log discarded." -ForegroundColor Gray
}