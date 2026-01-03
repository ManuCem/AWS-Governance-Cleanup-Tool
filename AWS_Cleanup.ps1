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
Write-Host "[5]  RDS Databases (Standard & Aurora)"
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

# --- INSTRUCTION FOR THE "MORE" PROMPT ---
Write-Host "`n" + ("-" * 50) -ForegroundColor Yellow
Write-Host "⚠️  IMPORTANT TIP FOR OUTPUT:" -ForegroundColor White -BackgroundColor DarkBlue
Write-Host "If the screen pauses and shows '-- More --' at the bottom:" -ForegroundColor Yellow
Write-Host "👉 PRESS 'Q' TO SKIP AND CONTINUE DELETING." -ForegroundColor White -BackgroundColor Red
Write-Host ("-" * 50) -ForegroundColor Yellow
Start-Sleep -Seconds 2 # Brief pause so you read the message

Write-Host "`n🔍 INITIALIZING INFRASTRUCTURE SCAN..." -ForegroundColor Gray

# 5. DECOMMISSIONING LOOP
foreach ($c in $choices) {
    
    # --- S3 ---
    if ($c -eq "1" -or $c -eq "10") {
        Write-Host "`n📦 [S3] Scanning..." -ForegroundColor Cyan
        $list = aws s3api list-buckets --query "Buckets[*].Name" --output text
        if ($list -and $list -ne "None") { 
            Write-Host "   > Found buckets. Deleting..." -ForegroundColor Yellow
            ($list -split "\s+") | ForEach-Object { aws s3 rb "s3://$_" --force; $terminationRegistry.S3 += $_ } 
        } else { Write-Host "   > No S3 buckets found." -ForegroundColor DarkGray }
    }

    # --- EC2 ---
    if ($c -eq "2" -or $c -eq "10") {
        Write-Host "`n💻 [EC2] Scanning..." -ForegroundColor Cyan
        $list = aws ec2 describe-instances --query "Reservations[*].Instances[*].InstanceId" --output text
        if ($list -and $list -ne "None") { 
            Write-Host "   > Found instances. Terminating... (Press 'Q' if you see --More--)" -ForegroundColor Yellow
            $ids = $list -split "\s+"; aws ec2 terminate-instances --instance-ids $ids; $terminationRegistry.EC2 += $ids 
        } else { Write-Host "   > No EC2 instances found." -ForegroundColor DarkGray }
    }

    # --- IAM ROLES ---
    if ($c -eq "3" -or $c -eq "10") {
        Write-Host "`n🔑 [IAM] Scanning Roles..." -ForegroundColor Cyan
        $list = aws iam list-roles --query "Roles[*].RoleName" --output text
        if ($list -and $list -ne "None") { 
            Write-Host "   > Found roles. Attempting deletion... (Press 'Q' if stuck)" -ForegroundColor Yellow
            ($list -split "\s+") | ForEach-Object { 
                aws iam delete-role --role-name $_ 2>$null
                if ($?) { $terminationRegistry.IAM += $_ }
            } 
        } else { Write-Host "   > No IAM roles found." -ForegroundColor DarkGray }
    }

    # --- LAMBDA ---
    if ($c -eq "4" -or $c -eq "10") {
        Write-Host "`n⚡ [Lambda] Scanning..." -ForegroundColor Cyan
        $list = aws lambda list-functions --query "Functions[*].FunctionName" --output text
        if ($list -and $list -ne "None") { 
            Write-Host "   > Found functions. Deleting..." -ForegroundColor Yellow
            ($list -split "\s+") | ForEach-Object { aws lambda delete-function --function-name $_; $terminationRegistry.Lambda += $_ } 
        } else { Write-Host "   > No Lambda functions found." -ForegroundColor DarkGray }
    }

    # --- RDS (Aurora/Standard) ---
    if ($c -eq "5" -or $c -eq "10") {
        Write-Host "`n🛢️  [RDS] Scanning Clusters..." -ForegroundColor Cyan
        $clusters = aws rds describe-db-clusters --query "DBClusters[*].DBClusterIdentifier" --output text
        if ($clusters -and $clusters -ne "None") { 
            Write-Host "   > Found clusters. Deleting... (Remember to press 'Q'!)" -ForegroundColor Yellow
            ($clusters -split "\s+") | ForEach-Object { aws rds delete-db-cluster --db-cluster-identifier $_ --skip-final-snapshot; $terminationRegistry.RDS += "Cluster: $_" } 
        } else { Write-Host "   > No Aurora Clusters found." -ForegroundColor DarkGray }

        Write-Host "🛢️  [RDS] Scanning Instances..." -ForegroundColor Cyan
        $instances = aws rds describe-db-instances --query "DBInstances[*].DBInstanceIdentifier" --output text
        if ($instances -and $instances -ne "None") { 
            Write-Host "   > Found instances. Deleting... (Press 'Q' to skip the details)" -ForegroundColor Yellow
            ($instances -split "\s+") | ForEach-Object { aws rds delete-db-instance --db-instance-identifier $_ --skip-final-snapshot; $terminationRegistry.RDS += "Instance: $_" } 
        } else { Write-Host "   > No RDS Instances found." -ForegroundColor DarkGray }
    }

    # --- DYNAMODB ---
    if ($c -eq "6" -or $c -eq "10") {
        Write-Host "`n📊 [DynamoDB] Scanning..." -ForegroundColor Cyan
        $list = aws dynamodb list-tables --query "TableNames[]" --output text
        if ($list -and $list -ne "None") { 
            Write-Host "   > Found tables. Deleting..." -ForegroundColor Yellow
            ($list -split "\s+") | ForEach-Object { aws dynamodb delete-table --table-name $_; $terminationRegistry.Dynamo += $_ } 
        } else { Write-Host "   > No DynamoDB tables found." -ForegroundColor DarkGray }
    }

    # --- EBS VOLUMES ---
    if ($c -eq "7" -or $c -eq "10") {
        Write-Host "`n💾 [EBS] Scanning..." -ForegroundColor Cyan
        $list = aws ec2 describe-volumes --query "Volumes[*].VolumeId" --output text
        if ($list -and $list -ne "None") { 
            Write-Host "   > Found volumes. Deleting..." -ForegroundColor Yellow
            ($list -split "\s+") | ForEach-Object { aws ec2 delete-volume --volume-id $_; $terminationRegistry.EBS += $_ } 
        } else { Write-Host "   > No EBS volumes found." -ForegroundColor DarkGray }
    }

    # --- CLOUDWATCH ---
    if ($c -eq "8" -or $c -eq "10") {
        Write-Host "`n📜 [CloudWatch] Scanning Logs..." -ForegroundColor Cyan
        $list = aws logs describe-log-groups --query "logGroups[*].logGroupName" --output text
        if ($list -and $list -ne "None") { 
            Write-Host "   > Found log groups. Deleting..." -ForegroundColor Yellow
            ($list -split "\s+") | ForEach-Object { aws logs delete-log-group --log-group-name $_; $terminationRegistry.Logs += $_ } 
        } else { Write-Host "   > No Log Groups found." -ForegroundColor DarkGray }
    }

    # --- GLUE ---
    if ($c -eq "9" -or $c -eq "10") {
        Write-Host "`n🧩 [Glue] Scanning..." -ForegroundColor Cyan
        if ($glueSubChoice -eq "1" -or $glueSubChoice -eq "4") {
            $list = aws glue get-crawlers --query "Crawlers[*].Name" --output text
            if ($list -and $list -ne "None") { 
                Write-Host "   > Deleting Crawlers..."
                ($list -split "\s+") | ForEach-Object { aws glue delete-crawler --name $_; $terminationRegistry.Glue += "Crawler: $_" } 
            } else { Write-Host "   > No Crawlers found." -ForegroundColor DarkGray }
        }
        if ($glueSubChoice -eq "2" -or $glueSubChoice -eq "4") {
            $list = aws glue get-databases --query "DatabaseList[*].Name" --output text
            if ($list -and $list -ne "None") { 
                Write-Host "   > Deleting Databases..."
                ($list -split "\s+") | ForEach-Object { aws glue delete-database --name $_; $terminationRegistry.Glue += "DB: $_" } 
            } else { Write-Host "   > No Glue Databases found." -ForegroundColor DarkGray }
        }
        if ($glueSubChoice -eq "3" -or $glueSubChoice -eq "4") {
            $list = aws glue get-jobs --query "Jobs[*].Name" --output text
            if ($list -and $list -ne "None") { 
                Write-Host "   > Deleting Jobs..."
                ($list -split "\s+") | ForEach-Object { aws glue delete-job --job-name $_; $terminationRegistry.Glue += "Job: $_" } 
            } else { Write-Host "   > No Glue Jobs found." -ForegroundColor DarkGray }
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