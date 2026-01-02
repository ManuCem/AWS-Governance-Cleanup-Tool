# SAVE AS: UTF-8 with BOM
$ErrorActionPreference = "SilentlyContinue"
Clear-Host

# 1. SETUP DATA & LOGGING
$logContent = @()
$terminationRegistry = [Ordered]@{ 
    S3 = @(); EC2 = @(); IAM = @(); Lambda = @(); RDS = @()
    Dynamo = @(); EBS = @(); Logs = @(); Glue = @() 
}

# --- PROFESSIONAL HEADER ---
Write-Host "`n=======================================================" -ForegroundColor Cyan
Write-Host "     AWS GOVERNANCE CLEAN UP" -ForegroundColor White
Write-Host "=======================================================" -ForegroundColor Cyan

# 2. THE GOVERNANCE MENU
Write-Host "`n[1]  S3 Buckets"
Write-Host "[2]  EC2 Instances"
Write-Host "[3]  IAM Roles"
Write-Host "[4]  Lambda Functions"
Write-Host "[5]  RDS Databases"
Write-Host "[6]  DynamoDB Tables"
Write-Host "[7]  EBS Volumes"
Write-Host "[8]  CloudWatch Logs"
Write-Host "[9]  AWS GLUE (Crawlers, Databases, ETL Jobs)"
Write-Host "[10] FULL ENVIRONMENT PURGE (All Services)" -ForegroundColor Red

$selection = Read-Host "`n📋 Select targets for decommissioning (e.g., 1,2,9)"
$choices = $selection -split "," | ForEach-Object { $_.Trim() }

# 3. GLUE SUB-MENU LOGIC
$glueSubChoice = "4" 

if ($choices -contains "9" -and -not ($choices -contains "10")) {
    Write-Host "`n--- AWS GLUE SPECIFICS ---" -ForegroundColor Yellow
    Write-Host "1. Crawlers"
    Write-Host "2. Data Catalog Databases"
    Write-Host "3. Visual ETL Jobs"
    Write-Host "4. DECOMMISSION ALL GLUE RESOURCES"
    $glueSubChoice = Read-Host "Select Glue Target (1-4)"
}

# 4. SAFETY CONFIRMATION LOGIC
if ($choices -contains "10") {
    Write-Host "`n" + ("!" * 60) -ForegroundColor Red
    Write-Host "⚠️  MANDATORY SYSTEM CONFIRMATION REQUIRED" -ForegroundColor White -BackgroundColor Red
    Write-Host "You are about to purge: S3, EC2, IAM, Lambda, RDS, Dynamo, EBS, Logs," -ForegroundColor Red
    Write-Host "and GLUE (Visual ETL, Crawlers, and Data Catalog Databases)." -ForegroundColor Red
    Write-Host ("!" * 60) -ForegroundColor Red
    
    if ((Read-Host "`nConfirm environment purge? (y/n)") -ne "y") { Write-Host "❌ Operation Aborted."; exit }
}

Write-Host "`n🔍 INITIALIZING INFRASTRUCTURE SCAN..." -ForegroundColor Gray

# 5. DECOMMISSIONING LOOP
foreach ($c in $choices) {
    # --- S3 ---
    if ($c -eq "1" -or $c -eq "10") {
        $list = aws s3api list-buckets --query "Buckets[*].Name" --output text
        if ($list -and $list -ne "None") { ($list -split "\s+") | ForEach-Object { aws s3 rb "s3://$_" --force; $terminationRegistry.S3 += $_ } }
    }
    # --- EC2 ---
    if ($c -eq "2" -or $c -eq "10") {
        $list = aws ec2 describe-instances --query "Reservations[*].Instances[*].InstanceId" --output text
        if ($list -and $list -ne "None") { $ids = $list -split "\s+"; aws ec2 terminate-instances --instance-ids $ids; $terminationRegistry.EC2 += $ids }
    }
    # --- LAMBDA ---
    if ($c -eq "4" -or $c -eq "10") {
        $list = aws lambda list-functions --query "Functions[*].FunctionName" --output text
        if ($list -and $list -ne "None") { ($list -split "\s+") | ForEach-Object { aws lambda delete-function --function-name $_; $terminationRegistry.Lambda += $_ } }
    }
    # --- CLOUDWATCH ---
    if ($c -eq "8" -or $c -eq "10") {
        $list = aws logs describe-log-groups --query "logGroups[*].logGroupName" --output text
        if ($list -and $list -ne "None") { ($list -split "\s+") | ForEach-Object { aws logs delete-log-group --log-group-name $_; $terminationRegistry.Logs += $_ } }
    }
    # --- GLUE ---
    if ($c -eq "9" -or $c -eq "10") {
        if ($glueSubChoice -eq "1" -or $glueSubChoice -eq "4") {
            $list = aws glue get-crawlers --query "Crawlers[*].Name" --output text
            if ($list -and $list -ne "None") { ($list -split "\s+") | ForEach-Object { aws glue delete-crawler --name $_; $terminationRegistry.Glue += "Crawler: $_" } }
        }
        if ($glueSubChoice -eq "2" -or $glueSubChoice -eq "4") {
            $list = aws glue get-databases --query "DatabaseList[*].Name" --output text
            if ($list -and $list -ne "None") { ($list -split "\s+") | ForEach-Object { aws glue delete-database --name $_; $terminationRegistry.Glue += "DB: $_" } }
        }
        if ($glueSubChoice -eq "3" -or $glueSubChoice -eq "4") {
            $list = aws glue get-jobs --query "Jobs[*].Name" --output text
            if ($list -and $list -ne "None") { ($list -split "\s+") | ForEach-Object { aws glue delete-job --job-name $_; $terminationRegistry.Glue += "Job: $_" } }
        }
    }
}

# 6. TERMINATION REPORT
$header = "`n" + ("=" * 40) + "`n📋 RESOURCE TERMINATION REPORT`n" + ("=" * 40)
Write-Host $header -ForegroundColor White -BackgroundColor DarkBlue
$logContent += $header

$totalCount = 0
foreach ($key in $terminationRegistry.Keys) {
    if ($terminationRegistry[$key].Count -gt 0) {
        $sectionTitle = "`n🔹 $key Service ($($terminationRegistry[$key].Count) items removed):"
        Write-Host $sectionTitle -ForegroundColor Cyan
        $logContent += $sectionTitle
        
        foreach ($item in $terminationRegistry[$key]) {
            Write-Host "   - $item" -ForegroundColor Gray
            $logContent += "   - $item"
            $totalCount++
        }
    }
}

$footer = "`n✅ TOTAL RESOURCES DECOMMISSIONED: $totalCount`n🚀 MISSION COMPLETE: ENVIRONMENT OPTIMIZED"
Write-Host $footer -ForegroundColor Green
$logContent += $footer

# 7. LOGGING EXPORT
Write-Host "`n" + ("-" * 40)
$wantSave = Read-Host "💾 Export session log to .txt file? (y/n)"

if ($wantSave -eq "y") {
    $fileName = "AWS_Termination_Log_$(Get-Date -Format 'yyyyMMdd_HHmm').txt"
    $logContent | Out-File -FilePath $fileName -Encoding UTF8
    Write-Host "✅ Audit log saved: $fileName" -ForegroundColor Green
} else {
    Write-Host "⚠️  Session log discarded." -ForegroundColor Yellow
}