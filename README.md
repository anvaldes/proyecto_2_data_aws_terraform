# 🔥 Simple PySpark Pipeline on AWS EMR with Terraform

This repository contains a lightweight **PySpark-based pipeline** that runs on **Amazon EMR**, designed to follow a minimal and reproducible workflow:

**➡️ Create Cluster → Run Job → Download Output → Terminate Cluster**

Additionally, infrastructure is provisioned using **Terraform**, and unit tests are performed with **Pytest**.

---

## ⚙️ Workflow Overview

```text
1. Create EMR Cluster
2. Upload PySpark Job to S3
3. Execute the job via EMR Step
4. Download results from S3
5. Terminate Cluster
```

---

## 🚀 Run PySpark Job on EMR

### 🛠️ Step 1: Create the EMR Cluster

```bash
aws emr create-cluster \
  --name "cluster-pyspark" \
  --release-label emr-6.15.0 \
  --applications Name=Spark \
  --instance-type m5.xlarge \
  --instance-count 1 \
  --ec2-attributes KeyName=mi-par-nuevo \
  --use-default-roles \
  --region us-east-1 \
  --no-auto-terminate
```

### ⚡ Step 2: Run the PySpark Job

```bash
# Upload the job script to S3
aws s3 cp job.py s3://proyecto-1-ml/scripts/job.py

# Submit the job to the cluster
aws emr add-steps \
  --cluster-id j-XXXXXXX \
  --region us-east-1 \
  --steps '[
    {
      "Type": "Spark",
      "Name": "Run PySpark Job",
      "ActionOnFailure": "CONTINUE",
      "Args": [
        "--deploy-mode", "cluster",
        "--master", "yarn",
        "s3://proyecto-1-ml/scripts/job.py"
      ]
    }
  ]'
```

### 📊 Step 3: Monitor Job Status

```bash
aws emr describe-step \
  --cluster-id j-XXXXXXX \
  --step-id s-YYYYYYY \
  --region us-east-1 \
  --query "Step.Status.State"
```

### 💾 Step 4: Download Results

```bash
mkdir -p output/job_simple
aws s3 cp s3://proyecto-1-ml/output/job_simple/ ./output/job_simple/ --recursive
```

### 🧹 Step 5: Terminate the Cluster

```bash
aws emr terminate-clusters \
  --cluster-id j-XXXXXXX \
  --region us-east-1
```

---
