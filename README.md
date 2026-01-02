# ☁️ AWS Governance & Cost Optimization Tool

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue?logo=powershell)
![AWS](https://img.shields.io/badge/AWS-CLI-orange?logo=amazon-aws)
![License](https://img.shields.io/badge/License-MIT-green)

A modular PowerShell automation utility designed for cloud governance and operational cost management.

The **AWS Governance Cleanup Tool** provides a structured, menu-driven interface to identify and decommission specific AWS resources (S3, EC2, Lambda, etc.) or execute a full environment audit and purge to eliminate unnecessary expenditure.

---

## ⚠️ INSTALLATION WARNING (Encoding)

**DO NOT COPY-PASTE THE CODE MANUALLY.**

This tool utilizes specific **UTF-8 with BOM** encoding to render the interface and status indicators correctly. Copying the raw text into a standard editor may corrupt the encoding, causing the script to fail.

### ✅ How to Install:
1. **Download the file:** Click the green `Code` button -> `Download ZIP`.
2. **Or Clone it:** `git clone https://github.com/ManuCem/AWS-Governance-Cleanup-Tool.git`
3. **Or Save Raw:** Right-click the `.ps1` file and select "Save link as..."

---

## 🚀 Key Features

* **Modular Governance:** Selectively decommission specific services without impacting critical infrastructure.
* **Cost Optimization:** Automatically targets unattached Elastic IPs and "Available" EBS Volumes to reduce OpEx.
* **Environment Deep-Cleaning:** Integrated logic for complex services including AWS Glue (Crawlers, Databases, and ETL Jobs).
* **Audit Trail:** Generates a local `.txt` report ("Graveyard Log") for compliance, detailing every resource ID terminated.
* **Safety Protocols:** Includes critical confirmation steps for high-impact "Nuclear" actions.

## 🎯 Supported Services

* **S3 Buckets** (Recursive/Force deletion)
* **EC2 Instances**
* **IAM Roles**
* **Lambda Functions**
* **RDS Databases**
* **DynamoDB Tables**
* **EBS Volumes**
* **CloudWatch Logs**
* **AWS Glue** (Includes Visual ETL, Crawlers, and Data Catalog)

---

## 🛠️ Prerequisites

1.  **AWS CLI:** Configured with administrative or appropriate cleanup permissions.
2.  **PowerShell:** Version 5.1 or Core 7+.
3.  **Execution Policy:** Enable script execution via:
    ```powershell
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    ```

---

## 💻 Usage

1. **Download the script** to your environment:
   ```bash
   wget https://raw.githubusercontent.com/ManuCem/AWS-Governance-Cleanup-Tool/main/AWS_Cleanup.ps1 (https://raw.githubusercontent.com/ManuCem/AWS-Governance-Cleanup-Tool/main/AWS_Cleanup.ps1)


