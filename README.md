# ☁️ AWS Cleanup & Cost Saving Tool

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue?logo=powershell)
![AWS](https://img.shields.io/badge/AWS-CLI-orange?logo=amazon-aws)
![License](https://img.shields.io/badge/License-MIT-green)

A PowerShell tool made to help manage AWS resources and reduce costs.

The **AWS Cleanup Tool** provides a simple, menu-driven interface to help you find and delete specific AWS services (S3, EC2, Lambda, etc.) or clean up your entire account to save money.

---

## ⚠️ INSTALLATION WARNING (Encoding)

**DO NOT COPY-PASTE THE CODE MANUALLY.**

This tool uses **UTF-8 with BOM** encoding to make the interface look correct. If you copy the text into a standard editor, the encoding might break and the script will fail.

### ✅ How to Install:
1. **Download the file:** Click the green `Code` button -> `Download ZIP`.
2. **Or Clone it:** `git clone https://github.com/ManuCem/AWS-Governance-Cleanup-Tool.git`
3. **Or Save Raw:** Right-click the `.ps1` file and select "Save link as..."

---

## 🚀 Key Features

* **Choose what to delete:** You can pick specific services so you don't delete important infrastructure.
* **Save Money:** It automatically finds and removes unused resources like Elastic IPs and EBS Volumes to lower your monthly bill.
* **Deep Cleaning:** Includes logic to clean complex services like AWS Glue (Crawlers, Databases, and Jobs).
* **Activity Log:** It creates a `.txt` file (a report) that lists every resource ID that was deleted for your records.
* **Safety:** The script asks you to confirm your choice before doing any major deletions.

## 🎯 Supported Services

* **S3 Buckets** (Force deletion)
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

1.  **AWS CLI:** Set up with the right permissions to delete resources.
2.  **PowerShell:** Version 5.1 or newer.
3.  **Execution Policy:** Run this command to allow the script to run:
    ```powershell
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    ```

---

## 💻 Usage

1. **Download the script** to your computer:
   ```bash
   wget [https://raw.githubusercontent.com/ManuCem/AWS-Governance-Cleanup-Tool/main/AWS_Cleanup.ps1](https://raw.githubusercontent.com/ManuCem/AWS-Governance-Cleanup-Tool/main/AWS_Cleanup.ps1)
