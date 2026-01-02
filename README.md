# ☁️ Destruction AWS Clean Up Tool

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue?logo=powershell)
![AWS](https://img.shields.io/badge/AWS-CLI-orange?logo=amazon-aws)
![License](https://img.shields.io/badge/License-MIT-green)

A modular PowerShell automation tool designed to manage cloud costs by purging AWS resources. 

The **Destruction AWS Clean Up Tool** provides a menu-driven interface to delete specific service resources (S3, EC2, Lambda, etc.) or execute a full environment wipe ("Nuclear Option") to prevent accidental billing after lab sessions or projects.

---

## ⚠️ INSTALLATION WARNING (Encoding)

**DO NOT COPY-PASTE THE CODE MANUALLY.**

This tool utilizes specific **UTF-8 with BOM** encoding to render the UI and status indicators correctly. Copying the raw text into a standard editor may break the encoding, causing the script to fail.

### ✅ How to Install:
1. **Download the file:** Click the green `Code` button -> `Download ZIP`.
2. **Or Clone it:** `git clone https://github.com/Excentrik/destruction-aws-cleanup.git`
3. **Or Save Raw:** Right-click the `.ps1` file and select "Save link as..."

---

## 🚀 Key Features

* **Modular Deletion:** Select specific services to target without affecting others.
* **Cost Optimization:** Automatically targets "hidden" costs like unattached Elastic IPs and Available EBS Volumes.
* **Deep Cleaning:** Includes logic for complex services like AWS Glue (Crawlers, Databases, ETL Jobs).
* **Audit Logging:** Generates a local `.txt` report ("Graveyard Log") detailing every resource ID terminated during the session.
* **Safety Prompts:** Includes critical confirmation steps for high-impact actions.

## 🎯 Supported Services

* **S3 Buckets** (Recursive deletion)
* **EC2 Instances**
* **IAM Roles**
* **Lambda Functions**
* **RDS Databases**
* **DynamoDB Tables**
* **EBS Volumes**
* **CloudWatch Logs**
* **AWS Glue**

---

## 🛠️ Prerequisites

1.  **AWS CLI:** Installed and configured with appropriate permissions.
    ```powershell
    aws configure
    ```
2.  **PowerShell:** Windows PowerShell 5.1 or Core 7+.
3.  **Execution Policy:** If running scripts for the first time, allow execution:
    ```powershell
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    ```

---

## 💻 Usage

1. Run the script from your terminal:
   ```powershell
   .\DestructionTool.ps1